
# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-prison_to_probation_update_queue"    = "offender-events-dev",
    "Digital-Prison-Services-dev-prison_to_probation_update_queue_dl" = "offender-events-dev"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value }
  dynamodb_policies = {
    message_dynamodb  = module.message_dynamodb.irsa_policy_arn,
    schedule_dynamodb = module.schedule_dynamodb.irsa_policy_arn
  }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = merge(local.sqs_policies, local.dynamodb_policies)
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

#  For deletion
locals {
  sqs_policies_old      = [for item in data.aws_ssm_parameter.irsa_policy_arns : item.value]
  dynamodb_policies_old = [module.message_dynamodb.irsa_policy_arn, module.schedule_dynamodb.irsa_policy_arn]
}
#  For deletion
module "app-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"

  eks_cluster_name = var.eks_cluster_name
  namespace        = var.namespace
  service_account  = "${var.application}-${var.environment}"
  role_policy_arns = concat(local.sqs_policies_old, local.dynamodb_policies_old)
}

data "aws_ssm_parameter" "irsa_policy_arns" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

data "aws_iam_policy" "sqs_policies" {
  for_each = local.sqs_policies
  arn      = each.value
}

# Combine all SQS policies
data "aws_iam_policy_document" "sqs_policies" {
  source_policy_documents = [for item in data.aws_iam_policy.sqs_policies : item.policy]
}