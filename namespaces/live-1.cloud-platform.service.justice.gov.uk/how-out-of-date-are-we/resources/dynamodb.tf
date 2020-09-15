
module "hoodaw_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.1.2"

  team_name              = var.team_name
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = "false"

  hash_key = "filename"
  range_key = "filename"
  enable_encryption = "false"
  enable_autoscaler = "false"
  aws_region = "eu-west-2"
}

resource "kubernetes_secret" "hoodaw_dynamodb" {
  metadata {
    name      = "hoodaw-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.message_dynamodb.table_name
    table_arn         = module.message_dynamodb.table_arn
    access_key_id     = module.message_dynamodb.access_key_id
    secret_access_key = module.message_dynamodb.secret_access_key
  }
}
