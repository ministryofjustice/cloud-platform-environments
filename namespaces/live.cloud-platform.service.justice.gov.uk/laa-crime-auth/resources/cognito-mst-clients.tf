# CRIME HIGHER BILLING

resource "aws_cognito_user_pool_client" "chb_client_dev" {
  name                                 = var.cognito_user_pool_chb_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.mst_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.mst_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "chb_client_tst" {
  name                                 = var.cognito_user_pool_chb_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.mst_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.mst_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "chb_client_uat" {
  name                                 = var.cognito_user_pool_chb_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.mst_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.mst_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "chb_client_prd" {
  name                                 = var.cognito_user_pool_chb_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.mst_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.mst_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# K8S SECRET
resource "kubernetes_secret" "aws_cognito_user_pool_mst_dev" {
  metadata {
    name      = "mst-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    chb_client_id     = aws_cognito_user_pool_client.chb_client_dev.id
    chb_client_secret = aws_cognito_user_pool_client.chb_client_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_mst_tst" {
  metadata {
    name      = "mst-tst-client-credentials"
    namespace = var.namespace
  }
  data = {
    chb_client_id     = aws_cognito_user_pool_client.chb_client_tst.id
    chb_client_secret = aws_cognito_user_pool_client.chb_client_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_mst_uat" {
  metadata {
    name      = "mst-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    chb_client_id     = aws_cognito_user_pool_client.chb_client_uat.id
    chb_client_secret = aws_cognito_user_pool_client.chb_client_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_mst_prd" {
  metadata {
    name      = "mst-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    chb_client_id     = aws_cognito_user_pool_client.chb_client_prd.id
    chb_client_secret = aws_cognito_user_pool_client.chb_client_prd.client_secret
  }
}