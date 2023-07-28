module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name      = var.eks_cluster_name
  service_account_name  = var.application
  namespace             = var.namespace

  role_policy_arns = {
    sqs = module.hmpps_tier_domain_events_queue.irsa_policy_arn
    dlq = module.hmpps_tier_domain_events_dead_letter_queue.irsa_policy_arn
    sns = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}