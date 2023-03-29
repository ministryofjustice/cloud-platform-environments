/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "apply_pipeline_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.3.1"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = "false"
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  aws_region             = "eu-west-2"
  namespace              = var.namespace

  hash_key = "commitSha"

}

resource "kubernetes_secret" "apply_pipeline_dynamodb" {
  metadata {
    name      = "apply-pipeline-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.apply_pipeline_dynamodb.table_name
    table_arn         = module.apply_pipeline_dynamodb.table_arn
    access_key_id     = module.apply_pipeline_dynamodb.access_key_id
    secret_access_key = module.apply_pipeline_dynamodb.secret_access_key
  }
}