module "ap_gh_collab_repo_tf_state_lock" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.5.0"

  team_name              = var.team_name
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = "true"
  namespace              = var.namespace

  hash_key          = "LockID"
  enable_encryption = "true"
  enable_autoscaler = "true"
}

resource "kubernetes_secret" "ap_gh_collab_repo_tf_state_lock" {
  metadata {
    name      = "ap-gh-collab-repo-tf-state-lock-table"
    namespace = var.namespace
  }

  data = {
    table_name        = module.ap_gh_collab_repo_tf_state_lock.table_name
    table_arn         = module.ap_gh_collab_repo_tf_state_lock.table_arn
    access_key_id     = module.ap_gh_collab_repo_tf_state_lock.access_key_id
    secret_access_key = module.ap_gh_collab_repo_tf_state_lock.secret_access_key
  }
}
