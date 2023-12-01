resource "aws_cognito_user_pool_client" "ccc_client_dev" {
  name                                 = var.cognito_user_pool_ccc_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.hardship_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.hardship_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccc_client_tst" {
  name                                 = var.cognito_user_pool_ccc_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.hardship_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.hardship_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccc_client_uat" {
  name                                 = var.cognito_user_pool_ccc_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.hardship_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.hardship_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccc_client_prd" {
  name                                 = var.cognito_user_pool_ccc_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.hardship_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.hardship_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# ORCHESTRATION SERVICE
resource "aws_cognito_user_pool_client" "orchestration_client_hardship_dev" {
  name                                 = var.cognito_user_pool_orchestration_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.hardship_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.hardship_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_hardship_tst" {
  name                                 = var.cognito_user_pool_orchestration_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.hardship_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.hardship_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_hardship_uat" {
  name                                 = var.cognito_user_pool_orchestration_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.hardship_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.hardship_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_hardship_prd" {
  name                                 = var.cognito_user_pool_orchestration_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.hardship_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.hardship_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# K8S SECRET
resource "kubernetes_secret" "aws_cognito_user_pool_hardship_dev" {
  metadata {
    name      = "hardship-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    ccc_client_id     = aws_cognito_user_pool_client.ccc_client_dev.id
    ccc_client_secret = aws_cognito_user_pool_client.ccc_client_dev.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_hardship_dev.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_hardship_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_hardship_tst" {
  metadata {
    name      = "hardship-tst-client-credentials"
    namespace = var.namespace
  }
  data = {
    ccc_client_id     = aws_cognito_user_pool_client.ccc_client_tst.id
    ccc_client_secret = aws_cognito_user_pool_client.ccc_client_tst.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_hardship_tst.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_hardship_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_hardship_uat" {
  metadata {
    name      = "hardship-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    ccc_client_id     = aws_cognito_user_pool_client.ccc_client_uat.id
    ccc_client_secret = aws_cognito_user_pool_client.ccc_client_uat.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_hardship_uat.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_hardship_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_hardship_prd" {
  metadata {
    name      = "hardship-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    ccc_client_id     = aws_cognito_user_pool_client.ccc_client_prd.id
    ccc_client_secret = aws_cognito_user_pool_client.ccc_client_prd.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_hardship_prd.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_hardship_prd.client_secret
  }
}