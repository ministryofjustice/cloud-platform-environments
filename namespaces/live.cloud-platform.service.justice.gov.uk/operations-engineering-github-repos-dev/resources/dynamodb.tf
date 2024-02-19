module "github_repos_dev_state_lock_table" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key          = "LockID"
  enable_encryption = "true"
  enable_autoscaler = "true"
}

resource "kubernetes_secret" "github_repos_dev_state_lock_table" {
  metadata {
    name      = "github-repos-dev-state-lock-table"
    namespace = var.namespace
  }

  data = {
    table_name = module.github_repos_dev_state_lock_table.table_name
    table_arn  = module.github_repos_dev_state_lock_table.table_arn
  }
}