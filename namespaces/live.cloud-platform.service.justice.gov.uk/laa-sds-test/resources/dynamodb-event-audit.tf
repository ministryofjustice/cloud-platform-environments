module "event_audit_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.1.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace


  hash_key       = "request_id"
  hash_key_type  = "S"
  range_key      = "filename_position"
  range_key_type = "N"



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

resource "kubernetes_secret" "event_audit_dynamodb" {
  metadata {
    name      = "laa-sds-event-audit-dynamodb-output"
    namespace = var.namespace
  }
  data = {
    table_name = module.event_audit_dynamodb.table_name
    table_arn  = module.event_audit_dynamodb.table_arn
  }
}

data "aws_iam_policy_document" "event_audit_db_access" {
  statement {
    actions   = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:DeleteItem",
    ]
    resources = [module.event_audit_dynamodb.table_arn]
  }
}

resource "aws_iam_policy" "event_auditdb_policy" {
  name        = "${var.namespace}-event_auditdb_policy"
  description = "Grants R/W access to specified DynamoDB table"
  policy      = data.aws_iam_policy_document.event_audit_db_access.json
}

data "aws_iam_policy_document" "event_audit_db_write_only_access" {
  statement {
    actions   = [
      "dynamodb:PutItem"
    ]
    resources = [module.event_audit_dynamodb.table_arn]
  }
}
resource "aws_iam_policy" "event_auditdb_write_only_policy" {
  name        = "${var.namespace}-event_auditdb_write_only_policy"
  description = "Grants write-access to specified DynamoDB table"
  policy      = data.aws_iam_policy_document.event_audit_db_write_only_access.json
}
