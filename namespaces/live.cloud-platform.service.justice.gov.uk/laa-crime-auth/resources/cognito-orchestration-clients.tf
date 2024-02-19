resource "aws_cognito_user_pool_client" "maat_orchestration_dev" {
  name                                 = var.cognito_user_pool_maat_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.orchestration_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.orchestration_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_orchestration_tst" {
  name                                 = var.cognito_user_pool_maat_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.orchestration_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.orchestration_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_orchestration_uat" {
  name                                 = var.cognito_user_pool_maat_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.orchestration_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.orchestration_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_orchestration_prd" {
  name                                 = var.cognito_user_pool_maat_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.orchestration_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.orchestration_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}


resource "kubernetes_secret" "aws_cognito_user_pool_orchestration_dev" {
  metadata {
    name      = "orchestration-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_orchestration_dev.id
    maat_client_secret = aws_cognito_user_pool_client.maat_orchestration_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_orchestration_tst" {
  metadata {
    name      = "orchestration-tst-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_orchestration_tst.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_orchestration_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_orchestration_uat" {
  metadata {
    name      = "orchestration-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_orchestration_uat.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_orchestration_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_orchestration_prd" {
  metadata {
    name      = "orchestration-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_orchestration_prd.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_orchestration_prd.client_secret
  }
}