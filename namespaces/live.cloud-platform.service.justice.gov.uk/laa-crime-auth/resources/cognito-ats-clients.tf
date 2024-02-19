resource "aws_cognito_user_pool_client" "maat_ats_client_dev" {
  name                                 = var.cognito_user_pool_maat_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.ats_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ats_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_ats_client_tst" {
  name                                 = var.cognito_user_pool_maat_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.ats_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ats_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_ats_client_uat" {
  name                                 = var.cognito_user_pool_maat_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.ats_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ats_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_ats_client_prd" {
  name                                 = var.cognito_user_pool_maat_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.ats_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ats_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_os_client_dev" {
  name                                 = var.cognito_user_pool_maat_os_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.ats_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ats_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_os_client_tst" {
  name                                 = var.cognito_user_pool_maat_os_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.ats_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ats_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_os_client_uat" {
  name                                 = var.cognito_user_pool_maat_os_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.ats_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ats_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_os_client_prd" {
  name                                 = var.cognito_user_pool_maat_os_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.ats_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.ats_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "kubernetes_secret" "aws_cognito_user_pool_ats_dev" {
  metadata {
    name      = "ats-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_ats_client_dev.id
    maat_client_secret = aws_cognito_user_pool_client.maat_ats_client_dev.client_secret
    maat_os_client_id     = aws_cognito_user_pool_client.maat_os_client_dev.id
    maat_os_client_secret = aws_cognito_user_pool_client.maat_os_client_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ats_tst" {
  metadata {
    name      = "ats-test-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_ats_client_tst.id
    maat_client_secret = aws_cognito_user_pool_client.maat_ats_client_tst.client_secret
    maat_os_client_id     = aws_cognito_user_pool_client.maat_os_client_tst.id
    maat_os_client_secret = aws_cognito_user_pool_client.maat_os_client_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ats_uat" {
  metadata {
    name      = "ats-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_ats_client_uat.id
    maat_client_secret = aws_cognito_user_pool_client.maat_ats_client_uat.client_secret
    maat_os_client_id     = aws_cognito_user_pool_client.maat_os_client_uat.id
    maat_os_client_secret = aws_cognito_user_pool_client.maat_os_client_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_ats_prd" {
  metadata {
    name      = "ats-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_ats_client_prd.id
    maat_client_secret = aws_cognito_user_pool_client.maat_ats_client_prd.client_secret
    maat_os_client_id     = aws_cognito_user_pool_client.maat_os_client_prd.id
    maat_os_client_secret = aws_cognito_user_pool_client.maat_os_client_prd.client_secret
  }
}