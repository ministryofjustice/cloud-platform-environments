module "test_dynamo_creation" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.2.0"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace
  aws_region             = "eu-west-2"

  hash_key  = "id"
  range_key = "deleteBy"
}

resource "kubernetes_secret" "example_team_dynamodb" {
  metadata {
    name      = "example-team-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.test_dynamo_creation.table_name
    table_arn         = module.test_dynamo_creation.table_arn
    access_key_id     = module.test_dynamo_creation.access_key_id
    secret_access_key = module.test_dynamo_creation.secret_access_key
  }
}
