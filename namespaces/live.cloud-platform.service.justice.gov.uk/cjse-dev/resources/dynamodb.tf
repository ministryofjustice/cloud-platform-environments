module "dynamodb-cluster" {
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

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dynamodb-cluster" {
  metadata {
    name      = "dynamodb-table-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.dynamodb-cluster.table_name
    table_arn         = module.dynamodb-cluster.table_arn
    #access_key_id     = module.dynamodb-cluster.access_key_id
    #secret_access_key = module.dynamodb-cluster.secret_access_key
  }
}
