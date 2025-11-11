# ORCHESTRATION SERVICE
resource "aws_cognito_user_pool_client" "orchestration_client_cas_dev" {
  name                                 = var.cognito_user_pool_orchestration_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.cas_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cas_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_cas_tst" {
  name                                 = var.cognito_user_pool_orchestration_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.cas_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cas_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_cas_uat" {
  name                                 = var.cognito_user_pool_orchestration_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.cas_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cas_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_cas_prd" {
  name                                 = var.cognito_user_pool_orchestration_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.cas_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cas_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# K8S SECRET
resource "kubernetes_secret" "aws_cognito_user_pool_cas_dev" {
  metadata {
    name      = "cas-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_cas_dev.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_cas_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_cas_tst" {
  metadata {
    name      = "cas-tst-client-credentials"
    namespace = var.namespace
  }
  data = {
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_cas_tst.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_cas_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_cas_uat" {
  metadata {
    name      = "cas-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_cas_uat.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_cas_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_cas_prd" {
  metadata {
    name      = "cas-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_cas_prd.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_cas_prd.client_secret
  }
}