module "cap_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  aws_region             = "eu-west-2"
  namespace              = var.namespace

  hash_key       = "userId"
  hash_key_type  = "S"

  range_key      = "pdfId"
  range_key_type = "S"
}

resource "kubernetes_secret" "cap_dynamodb" {
  metadata {
    name      = "cap-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name       = module.cap_dynamodb.table_name
    table_arn        = module.cap_dynamodb.table_arn
    access_key_id    = module.cap_dynamodb.access_key_id
    secret_access_key = module.cap_dynamodb.secret_access_key
  }
}
