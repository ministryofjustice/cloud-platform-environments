resource "aws_ssm_parameter" "application_insights_key_dev" {
  name        = "/application_insights/key-dev"
  type        = "SecureString"
  value       = "T3 KEY TO BE MODIFIED"
  description = "Application Insights key for dev (t3)"
  overwrite   = false
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_key_preprod" {
  name        = "/application_insights/key-preprod"
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
  name        = "/application_insights/key-prod"
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


resource "aws_ssm_parameter" "application_insights_application_id_dev" {
  name        = "/application_insights/application-id-dev"
  type        = "SecureString"
  value       = "T3 ApplicationId TO BE MODIFIED"
  description = "Application Insights ApplicationId for dev (t3)"
  overwrite   = false
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_application_id_preprod" {
  name        = "/application_insights/application-id-preprod"
  type        = "SecureString"
  value       = "PREPROD ApplicationId TO BE MODIFIED"
  description = "Application Insights ApplicationId for preprod"
  overwrite   = false
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "application_insights_application_id_prod" {
  name        = "/application_insights/application-id-prod"
  type        = "SecureString"
  value       = "PROD ApplicationId TO BE MODIFIED"
  description = "Application Insights ApplicationId for prod"
  overwrite   = false
  tags        = local.tags
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

