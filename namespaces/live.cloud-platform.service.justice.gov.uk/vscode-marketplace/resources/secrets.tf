# Creates an AWS Secrets Manager secret for the curator's GitHub API token,
# synced into the namespace as a Kubernetes Secret by External Secrets Operator.
#
# After this is applied, set the secret value ONCE in the AWS console (Secrets
# Manager) as JSON so the key lands in the k8s Secret:
#
#     {"github-token": "github_pat_xxxxxxxx"}
#
# External Secrets then materialises a Kubernetes Secret named
# `vscode-marketplace-curator` with key `github-token`, which the curator CronJob consumes

module "curator_github_token" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"

  # EKS configuration (auto-supplied by the cloud-platform-environments pipeline)
  eks_cluster_name = var.eks_cluster_name

  secrets = {
    "github-token" = {
      description             = "GitHub Token (public read-only) for curator repo trust scoring"
      recovery_window_in_days = 0
      k8s_secret_name         = "vscode-marketplace-curator"
    }
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}
