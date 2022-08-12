data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_region" "current" {}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.cluster_name == "live" ? "live-1" : var.cluster_name]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    SubnetType = "Private"
  }
}

data "aws_subnet" "private" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}

resource "aws_security_group" "efs_sg" {
  name        = "raz-efs-sg"
  description = "Allow VPC EFS traffic"
  vpc_id      = data.aws_vpc.selected.id
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [for s in data.aws_subnet.private : s.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [for s in data.aws_subnet.private : s.cidr_block]
  }
}

module "efs" {
  source    = "cloudposse/efs/aws"
  version   = "0.32.7"
  namespace = "raz"
  stage     = "test"
  name      = "app"
  region    = data.aws_region.current.name
  vpc_id    = data.aws_vpc.selected.id
  subnets   = data.aws_subnet_ids.private.ids
  #  allowed_security_group_ids = [aws_security_group.efs_sg.id]
  zone_id = []
}

resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "raz-efs"
  }
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
  mount_options       = ["uid=1000", "gid=1000"]
  parameters = {
    provisioningMode = "efs-ap"
  }
}

output "efs_id" {
  value = module.efs.id
}

resource "kubernetes_persistent_volume" "raz_vol" {
  metadata {
    name = "raz-vol"
  }
  spec {
    access_modes                     = ["ReadWriteMany"]
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "raz-efs"
    capacity = {
      storage = "2Gi"
    }
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = module.efs.id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "raz_claim" {
  metadata {
    name      = "raz-claim"
    namespace = "raz-test-not-one"
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "raz-efs"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.raz_vol.metadata.0.name
  }
}

data "aws_iam_policy_document" "efs_doc" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "sts:AssumeRoleWithWebIdentity"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "efs_policy" {
  name        = "efs-client-policy-${var.cluster_name}"
  path        = "/cloud-platform/"
  policy      = data.aws_iam_policy_document.efs_doc.json
  description = "Policy for EFS CSI driver"
}

module "efs_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.3"

  eks_cluster      = var.cluster_name
  namespace        = "raz-test-not-one"
  service_account  = "efs-sa"
  role_policy_arns = [aws_iam_policy.efs_policy.arn]
}
