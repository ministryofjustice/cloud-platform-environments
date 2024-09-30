module "hmpps-audit-api-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-audit-api"
  role_policy_arns = {
    (module.hmpps_audit_queue.sqs_name)                   = module.hmpps_audit_queue.irsa_policy_arn
    (module.hmpps_audit_dead_letter_queue.sqs_name)       = module.hmpps_audit_dead_letter_queue.irsa_policy_arn
    (module.hmpps_audit_users_queue.sqs_name)             = module.hmpps_audit_users_queue.irsa_policy_arn
    (module.hmpps_audit_users_dead_letter_queue.sqs_name) = module.hmpps_audit_users_dead_letter_queue.irsa_policy_arn
    s3                                                    = module.s3.irsa_policy_arn
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

module "s3-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "audit-s3-${var.environment-name}"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns = {
    s3 = aws_iam_policy.allow-irsa-read-write.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "aws_iam_policy" "allow-irsa-read-write" {
  name        = "audit-read-write"
  path        = "/cloud-platform/"
  policy      = data.aws_iam_policy_document.document.json
  description = "Policy for reading audit json files from audit s3 bucket"
}

data "aws_iam_policy_document" "document" {
  statement {
    actions = [
      "athena:CancelQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetWorkGroup",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetPartitions",
      "glue:BatchCreatePartition",
      "glue:GetDatabases",
      "glue:CreateTable",
      "glue:DeleteTable",
    ]
    resources = [*]
  }
}

resource "random_id" "hmpps-audit-id" {
  byte_length = 16
}

resource "aws_iam_user" "hmpps-audit-user" {
  name = "hmpps-audit-user-${random_id.hmpps-audit-id.hex}"
  path = "/system/hmpps-audit-user/"
}

resource "aws_iam_access_key" "hmpps-audit-user" {
  user = aws_iam_user.hmpps-audit-user.name
}

resource "aws_iam_user_policy" "hmpps-audit-policy" {
  name   = "hmpps-audit-${var.environment-name}-athena"
  policy = data.aws_iam_policy_document.document.json
  user   = aws_iam_user.hmpps-audit-user.name
}
