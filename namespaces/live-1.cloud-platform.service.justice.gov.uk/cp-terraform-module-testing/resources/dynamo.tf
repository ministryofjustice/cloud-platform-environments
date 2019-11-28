/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.0"

  team_name              = "example-team"
  business-unit          = "example-bu"
  application            = "cptf11app"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "example-team@digtal.justice.gov.uk"
  aws_region             = "eu-west-2"

  hash_key  = "example-hash"
  range_key = "example-range"
}

resource "kubernetes_secret" "example_team_dynamodb" {
  metadata {
    name      = "cp-team-dynamodb-output"
    namespace = "cp-terraform-module-testing"
  }

  data = {
    table_name        = module.example_team_dynamodb.table_name
    table_arn         = module.example_team_dynamodb.table_arn
    access_key_id     = module.example_team_dynamodb.access_key_id
    secret_access_key = module.example_team_dynamodb.secret_access_key
  }
}

