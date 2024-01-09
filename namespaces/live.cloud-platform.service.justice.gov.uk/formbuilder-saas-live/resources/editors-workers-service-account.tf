locals {
  sa_name = "formbuilder-editor-workers-live"
}

data "kubernetes_secret" "s3_bucket_arns" {
  metadata {
    name      = "policy-arns"
    namespace = var.namespace
  }
}

data "kubernetes_secret" "s3_bucket_arns_live" {
  metadata {
    name      = "live-s3-metadata-bucket-policy-arns"
    namespace = var.namespace
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  allow_self_assume_role     = false
  assume_role_condition_test = "StringEquals"
  create_role                = true
  force_detach_policies      = true
  role_name                  = "formbuilder-saas-live"
  role_policy_arns = {
    s3     = data.kubernetes_secret.s3_bucket_arns.data.service_metadata_bucket_irsa
    s3prod = data.kubernetes_secret.s3_bucket_arns_live.data.service_metadata_bucket_irsa
  }

  oidc_providers = {
    (data.aws_eks_cluster.eks_cluster.name) : {
      provider_arn               = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}"
      namespace_service_accounts = ["${var.namespace}:${local.sa_name}"]
    }
  }

  tags = {
    namespace = var.namespace
  }
}

resource "kubernetes_service_account" "editors_workers" {
  metadata {
    name      = local.sa_name
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role.iam_role_arn
    }
  }

  secret {
    name = "${local.sa_name}-token"
  }

  automount_service_account_token = true
}

resource "kubernetes_secret_v1" "editors_workers_token" {
  metadata {
    name      = "formbuilder-editor-workers-live-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = local.sa_name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.editors_workers
  ]
}
