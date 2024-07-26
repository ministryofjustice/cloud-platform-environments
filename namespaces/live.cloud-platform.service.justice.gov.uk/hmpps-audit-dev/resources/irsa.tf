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
    s3 = aws_iam_policy.allow-irsa-read.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "aws_iam_policy" "allow-irsa-read" {
  name        = "audit-read-only"
  path        = "/cloud-platform/"
  policy      = data.aws_iam_policy_document.document.json
  description = "Policy for reading audit json files from audit s3 bucket"
}

data "aws_iam_policy_document" "document" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.s3.bucket_arn,
      "${module.s3.bucket_arn}/*",
    ]
  }
}
