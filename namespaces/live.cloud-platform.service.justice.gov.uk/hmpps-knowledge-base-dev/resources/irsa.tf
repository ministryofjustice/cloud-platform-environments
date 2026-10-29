# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_audit_queue" = "hmpps-audit-dev"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns : item.name => item.value }
  irsa_policies = {
    equip_migration_queue  = module.equip_migration_queue.irsa_policy_arn
    hmpps_knowledge_base_s3_input = module.hmpps_knowledge_base_s3_input.irsa_policy_arn
    hmpps_knowledge_base_s3_data_store = module.hmpps_knowledge_base_s3_data_store.irsa_policy_arn
    hmpps_knowledge_base_s3_archive = module.hmpps_knowledge_base_s3_archive.irsa_policy_arn
  }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name

  service_account_name = "hmpps-knowledge-base"
  role_policy_arns     = merge(local.sqs_policies, local.irsa_policies)
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
