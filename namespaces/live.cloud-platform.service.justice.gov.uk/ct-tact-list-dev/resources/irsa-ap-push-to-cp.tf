# Allow the AP push bucket to write to CP S3 bucket

# This can't be used in a resource name, just within blocks
variable "task_sc" {
  description = "Descrption of the actions this module performs (in_snake_case)."
  type        = string
  default     = "push_from_ap_to_s3"
}

# Resource names should be scoped only within this module
resource "aws_iam_policy" "policy_resource" {
  # NB: IAM policy name must be unique within Cloud Platform
  name = "${var.namespace}-${var.environment}-ap-push-to-cp-policy"
  # data.[a].[b].json reads policy from the data "a" "b" block below 
  policy      = data.aws_iam_policy_document.policy_data.json
  description = "Allow Analytical Platform exporter to push data to CP S3 bucket."
}

data "aws_iam_policy_document" "policy_data" {
  statement {
    sid = "AllowAPDataExporterWriteToS3"
    # Policy for the AP bucket
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl",
    ]
    # ARN of the AP bucket
    resources = [
      "arn:aws:s3:::mojap-counter-terrorism-exports",
    ]
  }
}

# This module name can't collide with any other in this namespace
module "irsa_push_from_ap_to_s3" {
  # always replace with latest version from Github
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns = {
    s3   = module.s3.irsa_policy_arn
    irsa = aws_iam_policy.irsa.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

# Data from the module that needs to be stored as a kubernetes secret
resource "kubernetes_secret" "irsa_push_from_ap_to_s3" {
  metadata {
    name      = "${var.namespace}-${var.environment}-irsa-ap-push-to-cp"
    namespace = var.namespace
  }
  data = {
    role_name       = "module.irsa_${var.task_sc}.role_name"
    role_arn        = "module.irsa_${var.task_sc}.role_arn"
    service_account = "module.irsa_${var.task_sc}.service_account.name"
  }
}
