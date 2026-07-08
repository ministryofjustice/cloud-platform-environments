module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  service_account_name = "hmpps-appointment-reminders-ui"
  role_policy_arns = {
    audit = data.aws_ssm_parameter.audit_irsa_policy_arn.value
  }

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}
