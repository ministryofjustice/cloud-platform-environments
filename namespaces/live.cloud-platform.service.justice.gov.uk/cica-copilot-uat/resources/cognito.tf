resource "aws_cognito_user_pool_client" "client" {
  name                                 = "cica-copilot-pool-client-uat"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  allowed_oauth_flows                  = ["client_credentials"]
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
}

resource "aws_cognito_resource_server" "resource" {
  user_pool_id = aws_cognito_user_pool.pool.id

  identifier = "cica-copilot-resource-server-uat"
  name       = "cica-copilot-resource-server-uat"
  scope {
    scope_name        = "custom-scope-1"
    scope_description = "custom scope"
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "cica-copilot-uat"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool" "pool" {
  name = "cica-copilot-pool-uat"
  admin_create_user_config {
    allow_admin_create_user_only = true
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }
}