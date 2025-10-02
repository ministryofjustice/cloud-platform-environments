module "audit_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.1.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace


  hash_key       = "service_id"
  hash_key_type  = "S"
  range_key      = "file_id"
  range_key_type = "S"



  enable_encryption = "true"
  enable_autoscaler = "true"
  autoscale_max_read_capacity = 40
  autoscale_max_write_capacity = 40
  autoscale_min_read_capacity = 1
  autoscale_min_write_capacity = 1

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "audit_dynamodb" {
  metadata {
    name      = "laa-sds-audit-dynamodb-output"
    namespace = var.namespace
  }
  data = {
    table_name = module.audit_dynamodb.table_name
    table_arn  = module.audit_dynamodb.table_arn
  }
}

data "aws_iam_policy_document" "audit_db_access" {
  statement {
    actions   = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:DeleteItem",
    ]
    resources = [module.audit_dynamodb.table_arn]
  }
}

resource "aws_iam_policy" "auditdb_policy" {
  name        = "${var.namespace}-auditdb_policy"
  description = "Grants R/W access to specified DynamoDB table"
  policy      = data.aws_iam_policy_document.audit_db_access.json
}
