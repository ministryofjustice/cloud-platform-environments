module "app-irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = { sns = data.aws_ssm_parameter.irsa_policy_arns_sns.value }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  name = "/hmpps-domain-events-dev/sns/cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573/irsa-policy-arn"
}
