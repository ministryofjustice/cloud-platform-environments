resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }
}

#To add a new client to the user pool, copy line 13 - 23 with new 'cognito_user_pool_client_name'
resource "aws_cognito_user_pool_client" "maat_orch" {
  name                                 = var.cognito_user_pool_client_name_maat_orch
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "cma" {
  name                                 = var.cognito_user_pool_client_name_cma
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccp" {
  name                                 = var.cognito_user_pool_client_name_ccp
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ccc" {
  name                                 = var.cognito_user_pool_client_name_ccc
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "ats" {
  name                                 = var.cognito_user_pool_client_name_ats
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "evidence" {
  name                                 = var.cognito_user_pool_client_name_evidence
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "cda" {
  name                                 = var.cognito_user_pool_client_name_cda
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "caa" {
  name                                 = var.cognito_user_pool_client_name_caa
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "hardship" {
  name                                 = var.cognito_user_pool_client_name_hardship
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "dces_report" {
  name                                 = var.cognito_user_pool_client_name_dces_report
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "dces_drc" {
  name                                 = var.cognito_user_pool_client_name_dces_drc
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "cccd" {
  name                                 = var.cognito_user_pool_client_name_cccd
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "mlra" {
  name                                 = var.cognito_user_pool_client_name_mlra
  user_pool_id                         = aws_cognito_user_pool.pool.id
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource.scope_identifiers
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}

resource "aws_cognito_resource_server" "resource" {
  identifier = var.resource_server_identifier
  name       = var.resource_server_name

  scope {
    scope_name        = var.resource_server_scope_name
    scope_description = var.resource_server_scope_description
  }
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = var.cognito_user_pool_domain_name
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "kubernetes_secret" "aws_cognito_user_pool_client" {
  metadata {
    name      = "maat-api-cognito-client-secret"
    namespace = var.namespace
  }

  data = {
    maat_orch_id     = aws_cognito_user_pool_client.maat_orch.id
    maat_orch_secret = aws_cognito_user_pool_client.maat_orch.client_secret
    cma_id     = aws_cognito_user_pool_client.cma.id
    cma_secret = aws_cognito_user_pool_client.cma.client_secret
    ccp_id     = aws_cognito_user_pool_client.ccp.id
    ccp_secret = aws_cognito_user_pool_client.ccp.client_secret
    ccc_id     = aws_cognito_user_pool_client.ccc.id
    ccc_secret = aws_cognito_user_pool_client.ccc.client_secret
    ats_id     = aws_cognito_user_pool_client.ats.id
    ats_secret = aws_cognito_user_pool_client.ats.client_secret
    evidence_id     = aws_cognito_user_pool_client.evidence.id
    evidence_secret = aws_cognito_user_pool_client.evidence.client_secret
    cda_id     = aws_cognito_user_pool_client.cda.id
    cda_secret = aws_cognito_user_pool_client.cda.client_secret
    caa_id     = aws_cognito_user_pool_client.caa.id
    caa_secret = aws_cognito_user_pool_client.caa.client_secret
    hardship_id     = aws_cognito_user_pool_client.hardship.id
    hardship_secret = aws_cognito_user_pool_client.hardship.client_secret
    dces_report_id     = aws_cognito_user_pool_client.dces_report.id
    dces_report_secret = aws_cognito_user_pool_client.dces_report.client_secret
    dces_drc_id     = aws_cognito_user_pool_client.dces_drc.id
    dces_drc_secret = aws_cognito_user_pool_client.dces_drc.client_secret
    cccd_id     = aws_cognito_user_pool_client.cccd.id
    cccd_secret = aws_cognito_user_pool_client.cccd.client_secret
    mlra_id     = aws_cognito_user_pool_client.mlra.id
    mlra_secret = aws_cognito_user_pool_client.mlra.client_secret
  }
}