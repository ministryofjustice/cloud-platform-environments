resource "aws_cognito_user_pool_client" "maat_dev" {
  name                                 = var.cognito_user_pool_maat_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_tst" {
  name                                 = var.cognito_user_pool_maat_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_uat" {
  name                                 = var.cognito_user_pool_maat_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "maat_client_prd" {
  name                                 = var.cognito_user_pool_maat_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# CFE Crime

resource "aws_cognito_user_pool_client" "cfe_client_dev" {
  name                                 = var.cognito_user_pool_cfe_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "cfe_client_tst" {
  name                                 = var.cognito_user_pool_cfe_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "cfe_client_uat" {
  name                                 = var.cognito_user_pool_cfe_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "cfe_client_prd" {
  name                                 = var.cognito_user_pool_cfe_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# Functional Tests

resource "aws_cognito_user_pool_client" "functional_tests_client" {
  name                                 = var.cognito_user_pool_functional_tests_name
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}


# HARDSHIP SERVICE

resource "aws_cognito_user_pool_client" "laa_crime_hardship_dev" {
  name                                 = var.cognito_user_pool_hardship_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "laa_crime_hardship_tst" {
  name                                 = var.cognito_user_pool_hardship_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "laa_crime_hardship_uat" {
  name                                 = var.cognito_user_pool_hardship_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "laa_crime_hardship_prd" {
  name                                 = var.cognito_user_pool_hardship_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}


# ORCHESTRATION SERVICE
resource "aws_cognito_user_pool_client" "orchestration_client_cma_dev" {
  name                                 = var.cognito_user_pool_orchestration_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_cma_tst" {
  name                                 = var.cognito_user_pool_orchestration_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_cma_uat" {
  name                                 = var.cognito_user_pool_orchestration_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "orchestration_client_cma_prd" {
  name                                 = var.cognito_user_pool_orchestration_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.cma_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.cma_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

# K8S SECRET
resource "kubernetes_secret" "aws_cognito_user_pool_cma_dev" {
  metadata {
    name      = "cma-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_dev.id
    maat_client_secret = aws_cognito_user_pool_client.maat_dev.client_secret
    cfe_client_id     = aws_cognito_user_pool_client.cfe_client_dev.id
    cfe_client_secret = aws_cognito_user_pool_client.cfe_client_dev.client_secret
    functional_tests_client_id = aws_cognito_user_pool_client.functional_tests_client.id
    functional_tests_client_secret = aws_cognito_user_pool_client.functional_tests_client.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_cma_dev.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_cma_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_cma_tst" {
  metadata {
    name      = "cma-tst-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_tst.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_tst.client_secret
    cfe_client_id     = aws_cognito_user_pool_client.cfe_client_tst.id
    cfe_client_secret = aws_cognito_user_pool_client.cfe_client_tst.client_secret
    functional_tests_client_id = aws_cognito_user_pool_client.functional_tests_client.id
    functional_tests_client_secret = aws_cognito_user_pool_client.functional_tests_client.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_cma_tst.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_cma_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_cma_uat" {
  metadata {
    name      = "cma-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_uat.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_uat.client_secret
    cfe_client_id     = aws_cognito_user_pool_client.cfe_client_uat.id
    cfe_client_secret = aws_cognito_user_pool_client.cfe_client_uat.client_secret
    functional_tests_client_id = aws_cognito_user_pool_client.functional_tests_client.id
    functional_tests_client_secret = aws_cognito_user_pool_client.functional_tests_client.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_cma_uat.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_cma_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_cma_prd" {
  metadata {
    name      = "cma-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    maat_client_id     = aws_cognito_user_pool_client.maat_client_prd.id
    maat_client_secret = aws_cognito_user_pool_client.maat_client_prd.client_secret
    cfe_client_id     = aws_cognito_user_pool_client.cfe_client_prd.id
    cfe_client_secret = aws_cognito_user_pool_client.cfe_client_prd.client_secret
    functional_tests_client_id = aws_cognito_user_pool_client.functional_tests_client.id
    functional_tests_client_secret = aws_cognito_user_pool_client.functional_tests_client.client_secret
    orchestration_client_id = aws_cognito_user_pool_client.orchestration_client_cma_prd.id
    orchestration_client_secret = aws_cognito_user_pool_client.orchestration_client_cma_prd.client_secret
  }
}