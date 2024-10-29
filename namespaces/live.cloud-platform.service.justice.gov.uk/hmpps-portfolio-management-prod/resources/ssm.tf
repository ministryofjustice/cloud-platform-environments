resource "aws_ssm_parameter" "application_insights_key_t3" {
  name  = "/application_insights/key_t3"
  type  = "String"
  value = "T3 KEY TO BE MODIFIED"
  description = "Application Insights key for t3"
  overwrite = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_connection_string_t3" {
  name  = "/application_insights/connection_string_t3"
  type  = "String"
  value = "T3 CONNECTION STRING TO BE MODIFIED"
  description = "Application Insights connection string for t3"
  overwrite = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_key_preprod" {
  name  = "/application_insights/key_preprod"
  type  = "SecureString"
  value = "PREPROD KEY TO BE MODIFIED"
  description = "Application Insights key for preprod"
  overwrite = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_connection_string_preprod" {
  name  = "/application_insights/connection_string_preprod"
  type  = "SecureString"
  value = "PREPROD CONNECTION STRING TO BE MODIFIED"
  description = "Application Insights connection string for preprod"
  overwrite = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_key_prod" {
  name  = "/application_insights/key_prod"
  type  = "SecureString"
  value = "PROD KEY TO BE MODIFIED"
  description = "Application Insights key for prod"
  overwrite = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_connection_string_prod" {
  name  = "/application_insights/connection_string_prod"
  type  = "SecureString"
  value = "PREPROD CONNECTION STRING TO BE MODIFIED"
  description = "Application Insights connection string for preprod"
  overwrite = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}