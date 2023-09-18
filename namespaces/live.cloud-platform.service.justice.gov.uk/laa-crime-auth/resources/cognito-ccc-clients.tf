resource "aws_cognito_user_pool_client" "maat_client_ccc_dev" {
  name                                 = var.cognito_user_pool_maat_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.ccc_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccc_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_ccc_tst" {
  name                                 = var.cognito_user_pool_maat_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.ccc_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccc_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_ccc_uat" {
  name                                 = var.cognito_user_pool_maat_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.ccc_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccc_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_ccc_stg" {
  name                                 = var.cognito_user_pool_maat_client_name_stg
  user_pool_id                         = aws_cognito_user_pool.ccc_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccc_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_ccc_prd" {
  name                                 = var.cognito_user_pool_maat_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.ccc_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ccc_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccc_dev" {
  metadata {
    name      = "ccc-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_ccc_dev.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_ccc_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccc_tst" {
  metadata {
    name      = "ccc-tst-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_ccc_tst.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_ccc_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccc_uat" {
  metadata {
    name      = "ccc-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_ccc_uat.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_ccc_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccc_stg" {
  metadata {
    name      = "ccc-stg-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_ccc_stg.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_ccc_stg.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ccc_prd" {
  metadata {
    name      = "ccc-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_ccc_prd.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_ccc_prd.client_secret
  }
}