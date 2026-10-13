# -----------------------------------------------------------------------------
# DynamoDB Table for Transactions Audit
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "transactions_audit" {
  name         = var.dynamodb_transactions_audit_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "TRANSACTION_ID"
  range_key = "RECORD_TYPE"

  attribute {
    name = "TRANSACTION_ID"
    type = "S"
  }

  attribute {
    name = "RECORD_TYPE"
    type = "S"
  }

  attribute {
    name = "STATUS"
    type = "S"
  }

  attribute {
    name = "JOB_UUID"
    type = "S"
  }

  attribute {
    name = "LA_CASE_REF"
    type = "S"
  }

  global_secondary_index {
    name            = "status-index"
    hash_key        = "STATUS"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "job-uuid-index"
    hash_key        = "JOB_UUID"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "case-ref-index"
    hash_key        = "LA_CASE_REF"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = data.aws_kms_alias.cis-pp-key.target_key_arn
  }

  ttl {
    attribute_name = "TTL_EPOCH"
    enabled        = true
  }

  tags = merge(var.tags, {
    Name = var.dynamodb_transactions_audit_table_name
  })
}

resource "kubernetes_secret" "transactions_audit_dynamodb_output" {
  metadata {
    name      = "transactions-audit-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_arn  = aws_dynamodb_table.transactions_audit.arn
    table_name = aws_dynamodb_table.transactions_audit.name
  }
}
