module "dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  # Configuration
  hash_key  = "pk"
  range_key = "sk"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "dynamodb" {
  metadata {
    name      = "dynamodb-output"
    namespace = var.namespace
  }

  data = {
    irsa_policy_arn  = module.dynamodb.irsa_policy_arn
    table_arn = module.dynamodb.table_arn
    table_name = module.dynamodb.table_name
  }
}
