module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "prisoner-content-hub"
  namespace            = var.namespace # this is also used as a tag

  # Attach the appropriate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3     = module.drupal_content_storage_2.irsa_policy_arn
    s3prod = aws_iam_policy.s3_add_access_to_prod.arn
    rds    = module.drupal_rds.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "s3_add_access_to_prod" {
  version = "2012-10-17"
  statement {
    sid    = "AllowBucketActions"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-ee432bcfffe38a157f08669a6d4b7740",
      "arn:aws:s3:::cloud-platform-ee432bcfffe38a157f08669a6d4b7740/*"
    ]
  }
}

resource "aws_iam_policy" "s3_add_access_to_prod" {
  policy = data.aws_iam_policy_document.s3_add_access_to_prod.json
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "content-hub-irsa"
    namespace = var.namespace
  }

  data = {
    role = module.irsa.role_arn
  }
}

# Below is the IRSA config for hmpps-content-hub-ui

# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_prisoner_audit_queue" = "hmpps-audit-dev",
    "Digital-Prison-Services-dev-hmpps_audit_queue"          = "hmpps-audit-dev",
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
}

module "hmpps-content-hub-ui-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-content-hub-ui"
  role_policy_arns     = local.sqs_policies
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
