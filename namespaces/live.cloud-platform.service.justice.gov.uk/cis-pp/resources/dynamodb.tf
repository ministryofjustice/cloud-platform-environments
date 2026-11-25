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

# -----------------------------------------------------------------------------
# DynamoDB Table for BPS Metadata
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "bps_metadata" {
  name         = var.dynamodb_bps_metadata_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "JOB_UUID"

  attribute {
    name = "JOB_UUID"
    type = "S"
  }

  attribute {
    name = "STATUS"
    type = "S"
  }

  attribute {
    name = "CREATED_TIMESTAMP"
    type = "S"
  }

  attribute {
    name = "S3_PAYMENT_OBJECT_NAME"
    type = "S"
  }

  global_secondary_index {
    name            = "status-index"
    hash_key        = "STATUS"
    range_key       = "CREATED_TIMESTAMP"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "s3-object-name-index"
    hash_key        = "S3_PAYMENT_OBJECT_NAME"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = data.aws_kms_alias.cis-pp-key.target_key_arn
  }

  tags = merge(var.tags, {
    Name = var.dynamodb_bps_metadata_table_name
  })
}

resource "kubernetes_secret" "bps_metadata_dynamodb_output" {
  metadata {
    name      = "bps-metadata-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_arn  = aws_dynamodb_table.bps_metadata.arn
    table_name = aws_dynamodb_table.bps_metadata.name
  }
}
