module "test_dynamo_creation" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.2.0"

  team_name              = "test_team"
  business-unit          = "HQ"
  application            = "cloud platform"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platforms@digtal.justice.gov.uk"
  aws_region             = "eu-west-2"
  namespace              = "abundant-namespace-dev"

  hash_key  = "id"
  range_key = "deleteBy"
}

resource "kubernetes_secret" "example_team_dynamodb" {
  metadata {
    name      = "example-team-dynamodb-output"
    namespace = "abundant-namespace-dev"
  }

  data = {
    table_name        = module.test_dynamo_creation.table_name
    table_arn         = module.test_dynamo_creation.table_arn
    access_key_id     = module.test_dynamo_creation.access_key_id
    secret_access_key = module.test_dynamo_creation.secret_access_key
  }
}

