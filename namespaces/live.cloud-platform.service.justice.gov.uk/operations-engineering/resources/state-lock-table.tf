module "opseng_tf_state_lock" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key          = "LockID"
  enable_encryption = "false"
  enable_autoscaler = "true"
}

resource "kubernetes_secret" "opseng_tf_state_lock" {
  metadata {
    name      = "terraform-state-lock-table"
    namespace = var.namespace
  }

  data = {
    table_name = module.opseng_tf_state_lock.table_name
    table_arn  = module.opseng_tf_state_lock.table_arn
  }
}
