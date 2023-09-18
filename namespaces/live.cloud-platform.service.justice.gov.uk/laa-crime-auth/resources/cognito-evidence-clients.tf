resource "aws_cognito_user_pool_client" "ccp_client_dev" {
  name                                 = var.cognito_user_pool_ccp_client_name_dev
  user_pool_id                         = aws_cognito_user_pool.evidence_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.evidence_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccp_client_tst" {
  name                                 = var.cognito_user_pool_ccp_client_name_tst
  user_pool_id                         = aws_cognito_user_pool.evidence_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.evidence_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccp_client_uat" {
  name                                 = var.cognito_user_pool_ccp_client_name_uat
  user_pool_id                         = aws_cognito_user_pool.evidence_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.evidence_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccp_client_stg" {
  name                                 = var.cognito_user_pool_ccp_client_name_stg
  user_pool_id                         = aws_cognito_user_pool.evidence_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.evidence_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccp_client_prd" {
  name                                 = var.cognito_user_pool_ccp_client_name_prd
  user_pool_id                         = aws_cognito_user_pool.evidence_user_pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.evidence_resource_server.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "kubernetes_secret" "aws_cognito_user_pool_evidence_dev" {
  metadata {
    name      = "evidence-dev-client-credentials"
    namespace = var.namespace
  }
  data = {
    ccp_client_id     = aws_cognito_user_pool_client.ccp_client_dev.id
    ccp_client_secret = aws_cognito_user_pool_client.ccp_client_dev.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_evidence_tst" {
  metadata {
    name      = "evidence-test-client-credentials"
    namespace = var.namespace
  }
  data = {
    ccp_client_id     = aws_cognito_user_pool_client.ccp_client_tst.id
    ccp_client_secret = aws_cognito_user_pool_client.ccp_client_tst.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_evidence_uat" {
  metadata {
    name      = "evidence-uat-client-credentials"
    namespace = var.namespace
  }
  data = {
    ccp_client_id     = aws_cognito_user_pool_client.ccp_client_uat.id
    ccp_client_secret = aws_cognito_user_pool_client.ccp_client_uat.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_evidence_stg" {
  metadata {
    name      = "evidence-stg-client-credentials"
    namespace = var.namespace
  }
  data = {
    ccp_client_id     = aws_cognito_user_pool_client.ccp_client_stg.id
    ccp_client_secret = aws_cognito_user_pool_client.ccp_client_stg.client_secret
  }
}

resource "kubernetes_secret" "aws_cognito_user_pool_evidence_prd" {
  metadata {
    name      = "evidence-prd-client-credentials"
    namespace = var.namespace
  }
  data = {
    ccp_client_id     = aws_cognito_user_pool_client.ccp_client_prd.id
    ccp_client_secret = aws_cognito_user_pool_client.ccp_client_prd.client_secret
  }
}