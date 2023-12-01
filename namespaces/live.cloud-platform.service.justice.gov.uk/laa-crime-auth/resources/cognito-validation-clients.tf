# CMA SERVICE
resource "aws_cognito_user_pool_client" "cma_client_validation_dev" {
  name                                 = var.cognito_user_pool_cma_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "cma_client_validation_tst" {
  name                                 = var.cognito_user_pool_cma_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "cma_client_validation_uat" {
  name                                 = var.cognito_user_pool_cma_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "cma_client_validation_prd" {
  name                                 = var.cognito_user_pool_cma_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# CCP SERVICE
resource "aws_cognito_user_pool_client" "ccp_client_validation_dev" {
  name                                 = var.cognito_user_pool_ccp_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccp_client_validation_tst" {
  name                                 = var.cognito_user_pool_ccp_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccp_client_validation_uat" {
  name                                 = var.cognito_user_pool_ccp_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccp_client_validation_prd" {
  name                                 = var.cognito_user_pool_ccp_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# CCC SERVICE
resource "aws_cognito_user_pool_client" "ccc_client_validation_dev" {
  name                                 = var.cognito_user_pool_ccc_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccc_client_validation_tst" {
  name                                 = var.cognito_user_pool_ccc_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccc_client_validation_uat" {
  name                                 = var.cognito_user_pool_ccc_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccc_client_validation_prd" {
  name                                 = var.cognito_user_pool_ccc_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# HARDSHIP SERVICE
resource "aws_cognito_user_pool_client" "hardship_client_validation_dev" {
  name                                 = var.cognito_user_pool_hardship_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "hardship_client_validation_tst" {
  name                                 = var.cognito_user_pool_hardship_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "hardship_client_validation_uat" {
  name                                 = var.cognito_user_pool_hardship_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "hardship_client_validation_prd" {
  name                                 = var.cognito_user_pool_hardship_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# ORCHESTRATION SERVICE
resource "aws_cognito_user_pool_client" "orchestration_client_validation_dev" {
  name                                 = var.cognito_user_pool_orchestration_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_validation_tst" {
  name                                 = var.cognito_user_pool_orchestration_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_validation_uat" {
  name                                 = var.cognito_user_pool_orchestration_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_validation_prd" {
  name                                 = var.cognito_user_pool_orchestration_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.validation_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.validation_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# K8S SECRET
resource "kubernetes_secret" "aws_cognito_user_pool_validation_dev" {
  metadata {
    name      = "validation-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    cma_client_id     = aws_cognito_user_pool_client.cma_client_validation_dev.id
    cma_client_secret = aws_cognito_user_pool_client.cma_client_validation_dev.client_secret
    ccp_client_id     = aws_cognito_user_pool_client.ccp_client_validation_dev.id
    ccp_client_secret = aws_cognito_user_pool_client.ccp_client_validation_dev.client_secret
    ccc_client_id     = aws_cognito_user_pool_client.ccc_client_validation_dev.id
    ccc_client_secret = aws_cognito_user_pool_client.ccc_client_validation_dev.client_secret
    hardship_client_id = aws_cognito_user_pool_client.hardship_client_validation_dev.id
    hardship_client_secret = aws_cognito_user_pool_client.hardship_client_validation_dev.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_validation_dev.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_validation_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_validation_tst" {
  metadata {
    name      = "validation-tst-client-credentials"
    namespace = var.namespace
  }
  data = {
    cma_client_id     = aws_cognito_user_pool_client.cma_client_validation_tst.id
    cma_client_secret = aws_cognito_user_pool_client.cma_client_validation_tst.client_secret
    ccp_client_id     = aws_cognito_user_pool_client.ccp_client_validation_tst.id
    ccp_client_secret = aws_cognito_user_pool_client.ccp_client_validation_tst.client_secret
    ccc_client_id     = aws_cognito_user_pool_client.ccc_client_validation_tst.id
    ccc_client_secret = aws_cognito_user_pool_client.ccc_client_validation_tst.client_secret
    hardship_client_id = aws_cognito_user_pool_client.hardship_client_validation_tst.id
    hardship_client_secret = aws_cognito_user_pool_client.hardship_client_validation_tst.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_validation_tst.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_validation_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_validation_uat" {
  metadata {
    name      = "validation-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    cma_client_id     = aws_cognito_user_pool_client.cma_client_validation_uat.id
    cma_client_secret = aws_cognito_user_pool_client.cma_client_validation_uat.client_secret
    ccp_client_id     = aws_cognito_user_pool_client.ccp_client_validation_uat.id
    ccp_client_secret = aws_cognito_user_pool_client.ccp_client_validation_uat.client_secret
    ccc_client_id     = aws_cognito_user_pool_client.ccc_client_validation_uat.id
    ccc_client_secret = aws_cognito_user_pool_client.ccc_client_validation_uat.client_secret
    hardship_client_id = aws_cognito_user_pool_client.hardship_client_validation_uat.id
    hardship_client_secret = aws_cognito_user_pool_client.hardship_client_validation_uat.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_validation_uat.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_validation_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_validation_prd" {
  metadata {
    name      = "validation-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    cma_client_id     = aws_cognito_user_pool_client.cma_client_validation_prd.id
    cma_client_secret = aws_cognito_user_pool_client.cma_client_validation_prd.client_secret
    ccp_client_id     = aws_cognito_user_pool_client.ccp_client_validation_prd.id
    ccp_client_secret = aws_cognito_user_pool_client.ccp_client_validation_prd.client_secret
    ccc_client_id     = aws_cognito_user_pool_client.ccc_client_validation_prd.id
    ccc_client_secret = aws_cognito_user_pool_client.ccc_client_validation_prd.client_secret
    hardship_client_id = aws_cognito_user_pool_client.hardship_client_validation_prd.id
    hardship_client_secret = aws_cognito_user_pool_client.hardship_client_validation_prd.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_validation_prd.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_validation_prd.client_secret
  }
}