locals {
  data_store_general_role_arn = "arn:aws:iam::396913731313:role/emd_data_api_read_data_test"
}

moved {
  from = aws_ssm_parameter.emd_validation_db_read_data_prod
  to   = aws_ssm_parameter.data_store_general_role_arn
}

resource "aws_ssm_parameter" "data_store_general_role_arn" {
  name        = "/${var.namespace}/data_store_general_role_arn"
  type        = "SecureString"
  value       = local.data_store_general_role_arn
  description = "ARN of the role used to query general EM order data"
  tags        = local.tags
}