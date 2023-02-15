/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.2.4"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = "false"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  aws_region             = "eu-west-2"
  namespace              = var.namespace

  hash_key  = "example-hash"
  range_key = "example-range"

}

resource "kubernetes_secret" "example_team_dynamodb" {
  metadata {
    name      = "example-team-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.example_team_dynamodb.table_name
    table_arn         = module.example_team_dynamodb.table_arn
    access_key_id     = module.example_team_dynamodb.access_key_id
    secret_access_key = module.example_team_dynamodb.secret_access_key
  }
}

resource "kubernetes_secret" "example_two_dynamodb" {
  metadata {
    name      = "example-team-dynamodb-output"
    namespace = "abundant-namespace-staging"
  }

  data = {
    table_name        = module.example_team_dynamodb.table_name
    table_arn         = module.example_team_dynamodb.table_arn
    access_key_id     = module.example_team_dynamodb.access_key_id
    secret_access_key = module.example_team_dynamodb.secret_access_key
  }
}
