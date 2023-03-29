resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
  
}

resource "aws_cognito_user_pool_client" "client" {
  name                  = var.cognito_user_pool_client_name
  user_pool_id          = aws_cognito_user_pool.pool.id
  explicit_auth_flows   = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows   = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [var.resource_server_scope_name]
  prevent_user_existence_errors = "ENABLED"
  supported_identity_providers  = ["COGNITO"]
  generate_secret       = true
}

resource "aws_cognito_resource_server" "resource" {
  identifier = var.resource_server_identifier
  name       = var.resource_server_name

  scope {
    scope_name        = var.resource_server_scope_name
    scope_description = var.resource_server_scope_description
  }
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain          = var.cognito_user_pool_domain_name
  user_pool_id    = aws_cognito_user_pool.pool.id
}