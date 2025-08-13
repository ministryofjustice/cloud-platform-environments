resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }
}

#To add a new client to the user pool, copy line 13 - 23 with new 'cognito_user_pool_client_name'
resource "aws_cognito_user_pool_client" "maat" {
  name                                 = var.cognito_user_pool_client_name_maat
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "billing" {
  name                                 = var.cognito_user_pool_client_name_billing
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
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
  domain       = var.cognito_user_pool_domain_name
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "kubernetes_secret" "aws_cognito_user_pool_client" {
  metadata {
    name      = "maat-scheduled-tasks-cognito-client-secret"
    namespace = var.namespace
  }

  data = {
    maat_id     = aws_cognito_user_pool_client.maat.id
    maat_secret = aws_cognito_user_pool_client.maat.client_secret
    billing_id     = aws_cognito_user_pool_client.billing.id
    billing_secret = aws_cognito_user_pool_client.billing.client_secret
  }
}