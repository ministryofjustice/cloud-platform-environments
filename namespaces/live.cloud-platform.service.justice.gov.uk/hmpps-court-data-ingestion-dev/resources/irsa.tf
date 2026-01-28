
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
  sqs_policies = {
    hmpps_court_data_ingestion_queue             = module.hmpps_court_data_ingestion_queue.irsa_policy_arn,
    hmpps_court_data_ingestion_dead_letter_queue = module.hmpps_court_data_ingestion_dead_letter_queue.irsa_policy_arn,
  }
  # Here I'm trying to be able to push lambda code from our code repository from within kubernetes.
  lambda_policies = {
    hmmps_court_data_auth_lambda = aws_iam_role.lambda_role.arn
  }
  rds_policies = {
    rds_policy = module.hmpps-court-data-ingestion-api-rds.irsa_policy_arn
  }
  
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-court-data-ingestion-api"
  role_policy_arns     = merge(local.sqs_policies, local.sns_policies, local.lambda_policies, local.rds_policies)
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}


data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}
