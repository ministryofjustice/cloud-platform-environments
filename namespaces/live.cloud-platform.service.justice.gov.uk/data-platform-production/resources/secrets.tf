module "create_a_derived_table_github_self_hosted_runner_secrets" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "github-self-hosted-runners-create-a-derived-table-repo-url" = {
      description             = "GitHub self-hosted runner repo URL"
      recovery_window_in_days = 7
      k8s_secret_name         = "github-self-hosted-runners-create-a-derived-table-repo-url"
    },
    "github-self-hosted-runners-create-a-derived-table-repo-token" = {
      description             = "GitHub self-hosted runner repo token"
      recovery_window_in_days = 7
      k8s_secret_name         = "github-self-hosted-runners-create-a-derived-table-repo-token"
    }
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
