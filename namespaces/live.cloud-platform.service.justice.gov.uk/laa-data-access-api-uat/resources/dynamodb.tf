module "laa_data_access_api_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.1.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key               = "pk"
  hash_key_type          = "S"
  range_key              = "sk"
  range_key_type         = "S"
  enable_encryption      = "true"
  enable_autoscaler      = "true"
  autoscale_max_read_capacity = 40
  autoscale_max_write_capacity = 40
  autoscale_min_read_capacity = 1
  autoscale_min_write_capacity = 1

  attributes = [
    {
      name = "pk"
      type = "S"
    },
    {
      name = "sk"
      type = "S"
    },
    {
      name = "gs1pk"
      type = "S"
    },
    {
      name = "gs1sk"
      type = "S"
    },
    {
      name = "gs2pk"
      type = "S"
    },
    {
      name = "gs2sk"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name               = "gs-index-1"
      hash_key           = "gs1pk"
      range_key          = "gs1sk"
      projection_type    = "INCLUDE"
      non_key_attributes = ["pk", "sk", "s3location"]
      read_capacity      = 5
      write_capacity     = 5
    },
    {
      name               = "gs-index-2"
      hash_key           = "gs2pk"
      range_key          = "gs2sk"
      projection_type    = "INCLUDE"
      non_key_attributes = ["pk", "sk", "s3location", "createdAt"]
      read_capacity      = 5
      write_capacity     = 5
    }
  ]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "laa_data_access_api_dynamodb" {
  metadata {
    name      = "domain_events"
    namespace = var.namespace
  }
  data = {
    table_name = module.laa_data_access_api_dynamodb.table_name
    table_arn  = module.laa_data_access_api_dynamodb.table_arn
  }
}

data "aws_iam_policy_document" "laa_data_access_api_db_access" {
  statement {
    actions   = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    resources = [module.laa_data_access_api_dynamodb.table_arn]
  }
}

resource "aws_iam_policy" "laa_data_access_api_db_policy" {
  name        = "${var.namespace}-laa-data-access-api-db-policy"
  description = "Grants R/W access to specified DynamoDB table"
  policy      = data.aws_iam_policy_document.laa_data_access_api_db_access.json
}
