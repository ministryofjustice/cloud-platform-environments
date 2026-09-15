locals {
  sqs_queues = {
    "Digital-Prison-Services-${var.environment}-hmpps_person_on_probation_audit_queue" = "hmpps-audit-${var.environment}",
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
}

module "people-on-probation-ui-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name   = "hmpps-people-on-probation-ui"
  role_policy_arns       = local.sqs_policies
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

# Grants the API's service account read/write access to the documents S3 bucket (s3.tf) -
# it's the only service that talks to that bucket directly.
module "people-on-probation-api-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "hmpps-people-on-probation-api"
  role_policy_arns = {
    documents_s3 = module.hmpps_people_on_probation_documents_s3_bucket.irsa_policy_arn
  }
}