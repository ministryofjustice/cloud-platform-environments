
module "message_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.1"

  team_name              = var.team_name
  application            = var.application
  business-unit          = var.business-unit
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  is-production          = "false"

  hash_key       = "id"
  range_key      = "bookingId"
  range_key_type = "N"
  ttl_attribute  = "deleteBy"
}

resource "kubernetes_secret" "message_dynamodb" {
  metadata {
    name      = "message-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.message_dynamodb.table_name
    table_arn         = module.message_dynamodb.table_arn
    access_key_id     = module.message_dynamodb.access_key_id
    secret_access_key = module.message_dynamodb.secret_access_key
  }
}

module "schedule_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.1"

  team_name              = var.team_name
  application            = var.application
  business-unit          = var.business-unit
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  is-production          = "false"

  hash_key = "_id"
}

resource "kubernetes_secret" "schedule_dynamodb" {
  metadata {
    name      = "schedule-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.schedule_dynamodb.table_name
    table_arn         = module.schedule_dynamodb.table_arn
    access_key_id     = module.schedule_dynamodb.access_key_id
    secret_access_key = module.schedule_dynamodb.secret_access_key
  }
}

