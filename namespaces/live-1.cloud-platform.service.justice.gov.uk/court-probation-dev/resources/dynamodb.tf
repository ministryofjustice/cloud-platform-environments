
provider "aws" {
  region = "eu-west-2"
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "court_case_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.1.2"

  team_name              = "court-probation-team"
  application            = "Court Case Service"
  business-unit          = var.business-unit
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  is-production          = "false"

  hash_key  = "pk"
  range_key = "sk"
}

resource "kubernetes_secret" "court_case_dynamodb" {
  metadata {
    name      = "court-case-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.court_case_dynamodb.table_name
    table_arn         = module.court_case_dynamodb.table_arn
    access_key_id     = module.court_case_dynamodb.access_key_id
    secret_access_key = module.court_case_dynamodb.secret_access_key
  }
}

