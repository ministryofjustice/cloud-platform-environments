data  "aws_ssm_parameter" "data_store_cpr_ingestion_role_arn_dev" {
  name = "/${var.namespace}/data_store_cpr_ingestion_role_arn_dev"
  with_decryption = true
}

data  "aws_ssm_parameter" "data_store_cemo_ingestion_role_arn_dev" {
  name = "/${var.namespace}/data_store_cemo_ingestion_role_arn_dev"
  with_decryption = true
}

data  "aws_ssm_parameter" "data_store_cpr_ingestion_role_arn_test" {
  name = "/${var.namespace}/data_store_cpr_ingestion_role_arn_test"
  with_decryption = true
}

data  "aws_ssm_parameter" "data_store_cemo_ingestion_role_arn_test" {
  name = "/${var.namespace}/data_store_cemo_ingestion_role_arn_test"
  with_decryption = true
}

resource "aws_ssm_parameter" "data_store_cpr_ingestion_role_arn_dev" {
  name        = "/${var.namespace}/data_store_cpr_ingestion_role_arn_dev"
  type        = "SecureString"
  # This value must be replaced with a genuine role ARN using AWS CLI
  value       = "arn:aws:iam::0000000000000:role/general-placeholder"
  description = "ARN of the role used to ingest data from CPR relating to EM order data for dev account"
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "data_store_cemo_ingestion_role_arn_dev" {
  name        = "/${var.namespace}/data_store_cemo_ingestion_role_arn_dev"
  type        = "SecureString"
  # This value must be replaced with a genuine role ARN using AWS CLI
  value       = "arn:aws:iam::0000000000000:role/general-placeholder"
  description = "ARN of the role used to ingest data from CEMO relating to EM order data for dev account"
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "data_store_cpr_ingestion_role_arn_test" {
  name        = "/${var.namespace}/data_store_cpr_ingestion_role_arn_test"
  type        = "SecureString"
  # This value must be replaced with a genuine role ARN using AWS CLI
  value       = "arn:aws:iam::0000000000000:role/general-placeholder"
  description = "ARN of the role used to ingest data from CPR relating to EM order data for dev account"
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "data_store_cemo_ingestion_role_arn_test" {
  name        = "/${var.namespace}/data_store_cemo_ingestion_role_arn_test"
  type        = "SecureString"
  # This value must be replaced with a genuine role ARN using AWS CLI
  value       = "arn:aws:iam::0000000000000:role/general-placeholder"
  description = "ARN of the role used to ingest data from CEMO relating to EM order data for dev account"
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
