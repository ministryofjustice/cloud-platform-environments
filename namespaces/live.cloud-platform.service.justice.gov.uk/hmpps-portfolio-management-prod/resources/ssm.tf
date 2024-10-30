resource "aws_ssm_parameter" "application_insights_key_t3" {
  name        = "/application_insights/key_t3"
  type        = "String"
  value       = "T3 KEY TO BE MODIFIED"
  description = "Application Insights key for t3"
  overwrite   = false
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_key_preprod" {
  name        = "/application_insights/key_preprod"
  type        = "SecureString"
  value       = "PREPROD KEY TO BE MODIFIED"
  description = "Application Insights key for preprod"
  overwrite   = false
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_key_prod" {
  name        = "/application_insights/key_prod"
  type        = "SecureString"
  value       = "PROD KEY TO BE MODIFIED"
  description = "Application Insights key for prod"
  overwrite   = false
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

