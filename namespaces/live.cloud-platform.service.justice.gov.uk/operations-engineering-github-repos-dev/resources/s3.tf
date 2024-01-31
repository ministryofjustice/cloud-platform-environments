
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}

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
