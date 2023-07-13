module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns = {
    message_dynamodb  = module.message_dynamodb.irsa_policy_arn
    schedule_dynamodb = module.schedule_dynamodb.irsa_policy_arn
    sqs               = module.prison-to-probation-update-queue.irsa_policy_arn
    dlq               = module.prison-to-probation-update-dlq.irsa_policy_arn
    sns               = data.aws_ssm_parameter.hmpps-domain-events-policy-arn.value
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
