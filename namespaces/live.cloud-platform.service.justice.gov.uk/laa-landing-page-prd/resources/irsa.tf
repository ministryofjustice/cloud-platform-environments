module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "irsa-laa-landing-page-${var.environment}"
  namespace            = var.namespace
  
  role_policy_arns = {
    sqs = data.aws_ssm_parameter.sqs_policy_arn.value
    rds = module.rds.irsa_policy_arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
