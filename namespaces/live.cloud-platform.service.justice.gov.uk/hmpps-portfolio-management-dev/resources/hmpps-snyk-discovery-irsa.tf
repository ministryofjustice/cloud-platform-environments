# IRSA service account for hmpps-snyk-discovery workload pods.
# The deployment/helm values must set serviceAccountName to this value.
module "hmpps_snyk_discovery_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-snyk-discovery"

  role_policy_arns = {
    ecr_hmpps_business_unit_pull = aws_iam_policy.hmpps_business_unit_ecr_pull.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = "hmpps-snyk-discovery"
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
