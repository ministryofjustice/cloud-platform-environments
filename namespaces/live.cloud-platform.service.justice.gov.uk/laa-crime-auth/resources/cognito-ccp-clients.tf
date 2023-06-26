resource "aws_cognito_user_pool_client" "maat_client_ccp_dev" {
  name                                 = var.cognito_user_pool_maat_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.ccp_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccp_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_ccp_tst" {
  name                                 = var.cognito_user_pool_maat_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.ccp_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccp_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_ccp_uat" {
  name                                 = var.cognito_user_pool_maat_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.ccp_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccp_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_ccp_stg" {
  name                                 = var.cognito_user_pool_maat_client_name_stg
  user_pool_id                         = aws_cognito_user_pool.ccp_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccp_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_ccp_prd" {
  name                                 = var.cognito_user_pool_maat_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.ccp_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccp_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccp_dev" {
  metadata {
    name      = "ccp-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_dev.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccp_tst" {
  metadata {
    name      = "ccp-tst-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_tst.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccp_uat" {
  metadata {
    name      = "ccp-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_uat.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccp_stg" {
  metadata {
    name      = "ccp-stg-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_stg.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_stg.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccp_prd" {
  metadata {
    name      = "ccp-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_prd.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_prd.client_secret
  }
}