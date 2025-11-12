# Create an EFS file system and Access Point for Alfresco for use as a shared file system for the filestore service.
# The filestore service is used by Alfresco to transform content files outside of the database.
# A persistent shared file system is required for this service to work correctly in a multi-replica setup.
# This EFS should ONLY be mounted by the Alfresco pods in this namespace.
# The EFS access is restricted via an IAM policy attached to the IRSA role used by the Alfresco pods.
resource "aws_efs_file_system" "alfresco_efs_fs" {
  creation_token = var.namespace
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  tags = {
    name                   = "${var.namespace}-efs-fs"
    application            = var.application
    business_unit          = var.business_unit
    environment_name       = var.environment_name
    infrastructure_support = var.infrastructure_support
    is_production          = var.is_production
    namespace              = var.namespace
    team_name              = var.team_name
  }
}

resource "aws_efs_access_point" "alfresco_efs_ap" {
  file_system_id = aws_efs_file_system.alfresco_efs_fs.id
  # OS user and group applied to all file system requests made using the access point:
  posix_user {
    uid = 33030 # sfs user UID
    gid = 1000 # Alfresco group GID
  }
  # Directory on the Amazon EFS file system that the access point provides access to:
  root_directory {
    path = "/${var.namespace}"
    creation_info {
      owner_uid = 33030 # sfs user UID
      owner_gid = 1000 # Alfresco group GID
      permissions = "750"
    }
  }
  tags = {
    name                   = "${var.namespace}-efs-ap"
    application            = var.application
    business_unit          = var.business_unit
    environment_name       = var.environment_name
    infrastructure_support = var.infrastructure_support
    is_production          = var.is_production
    namespace              = var.namespace
    team_name              = var.team_name
  }
}

# This makes the EFS IDs available to the Helm chart by storing them in a ConfigMap
resource "kubernetes_config_map" "alfresco_efs_config" {
  metadata {
    name      = "alfresco-efs-config"
    namespace = var.namespace
  }

  data = {
    FILESYSTEMID  = aws_efs_file_system.alfresco_efs_fs.id
    ACCESSPOINTID = aws_efs_access_point.alfresco_efs_ap.id
  }
}

# IAM policy details for EFS access via IRSA.
# Once a policy is attached to the EFS file system, only the pods with this role will be able to connect to it.
data "aws_iam_policy_document" "efs_policy_document" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    effect = "Allow"
    resources = [
      aws_efs_file_system.alfresco_efs_fs.arn,
      aws_efs_access_point.alfresco_efs_ap.arn
    ]
    # Prevent access to the EFS file system by clients that are not using file system mount targets
    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values   = ["true"]
    }
  }
}

# Create the EFS IAM policy to be used by IRSA for accessing the EFS
resource "aws_iam_policy" "efs_policy" {
  name        = "${var.namespace}-efs-policy"
  policy      = data.aws_iam_policy_document.efs_policy_document.json
}
# This policy is then attached to the IRSA role in irsa.tf