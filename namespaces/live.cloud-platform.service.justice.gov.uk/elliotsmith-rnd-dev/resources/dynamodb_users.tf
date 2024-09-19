module "dynamodb_users_table" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  hash_key  = "guid"
  range_key = "created_at"
  attributes = [
    {
      name = "guid"
      type = "S"
    },
    {
      name = "created_at"
      type = "S"
    }
  ]
}

data "aws_iam_policy_document" "dynamodb_users_table_access" {
  statement {
    actions   = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:DeleteItem",
    ]
    resources = [module.dynamodb_users_table.table_arn]
  }
}

resource "aws_iam_policy" "dynamodb_users_table_policy" {
  name        = "${var.namespace}-users_table_policy"
  description = "Grants rw access to specified DynamoDB table"
  policy      = data.aws_iam_policy_document.dynamodb_users_table_access.json
}

resource "kubernetes_secret" "dynamodb_users_table_output" {
  metadata {
    name      = "dynamodb-users-table-output"
    namespace = var.namespace
  }

  data = {
    table_name = module.dynamodb_users_table.table_name
    table_arn  = module.dynamodb_users_table.table_arn
  }
}
