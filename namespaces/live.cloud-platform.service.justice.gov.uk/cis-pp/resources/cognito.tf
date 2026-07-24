# =============================================================================
# Auth Module - Cognito User Pool & Amplify
# =============================================================================

# -----------------------------------------------------------------------------
# Cognito User Pool
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool" "main" {
  name           = var.user_pool_name
  user_pool_tier = "PLUS"
  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Password policy
  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_uppercase                = var.password_require_uppercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  # Passwordless sign-in policy
  sign_in_policy {
    allowed_first_auth_factors = var.allowed_auth_factors
  }

  # User attribute configuration
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  # Email configuration — SES DEVELOPER mode removes the 50 emails/day limit
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
    #source_arn            = aws_sesv2_email_identity.main.arn
    #from_email_address    = "noreply@${var.ses_domain}"
  }

  # Schema attributes
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                     = "name"
    attribute_data_type      = "String"
    required                 = false
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Custom attribute: cis-role (mandatory for role-based access control)
  schema {
    name                     = "cis-role"
    attribute_data_type      = "String"
    required                 = false # Custom attributes cannot be required at pool level
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_configuration != "OFF" ? [1] : []
    content {
      enabled = true
    }
  }

  # Admin create user config
  admin_create_user_config {
    allow_admin_create_user_only = var.allow_admin_create_user_only

    invite_message_template {
      email_subject = "Your ${var.environment} CIS account"
      email_message = "Your username is {username} and temporary password is {####}."
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }
}

# -----------------------------------------------------------------------------
# Cognito User Pool Domain
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.main.id
}

# -----------------------------------------------------------------------------
# Cognito User Pool Client
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.environment}-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_AUTH", # Required for passwordless (email OTP, passkeys)
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  supported_identity_providers = ["COGNITO", "EntraID"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true

  prevent_user_existence_errors = "ENABLED"

  # Attribute permissions - allow read/write of custom attributes
  read_attributes  = ["email", "name", "custom:cis-role"]
  write_attributes = ["email", "name", "custom:cis-role"]

  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  depends_on = [aws_cognito_identity_provider.entra]
}

resource "kubernetes_secret" "cognito_user_pool_client" {
  metadata {
    name      = "${var.namespace}-cognito-user-pool-client"
    namespace = var.namespace
  }
  data = {
    client_id     = aws_cognito_user_pool_client.main.id
    client_secret = aws_cognito_user_pool_client.main.client_secret
  }
}

data "aws_secretsmanager_secret" "cognito_test_user" {
  name = module.cis_pp_cognito_test_user_secret.secret_names["cis-pp-cognito-test-user-secret"]
}

data "aws_secretsmanager_secret_version" "cognito_test_user" {
  secret_id = data.aws_secretsmanager_secret.cognito_test_user.id
}

resource "aws_cognito_user" "test" {
  user_pool_id = aws_cognito_user_pool.main.id
  username     = "stefan.hristov1@justice.gov.uk"

  attributes = {
    cis-role       = "viewer"
    email          = "stefan.hristov1@justice.gov.uk"
    email_verified = "true"
  }

  temporary_password = jsondecode(data.aws_secretsmanager_secret_version.cognito_test_user.secret_string)["CIS_PP_COGNITO_TEST_USER_PASS"]
  message_action     = "SUPPRESS"
}

# -----------------------------------------------------------------------------
# Entra ID (OIDC) Identity Provider
# -----------------------------------------------------------------------------
data "aws_secretsmanager_secret" "entra_nle_client_id" {
  name = module.cis_pp_entra_nle_client_id.secret_names["cis-pp-entra-nle-client-id"]
}

data "aws_secretsmanager_secret_version" "entra_nle_client_id" {
  secret_id = data.aws_secretsmanager_secret.entra_nle_client_id.id
}

data "aws_secretsmanager_secret" "entra_nle_client_secret" {
  name = module.cis_pp_entra_nle_client_secret.secret_names["cis-pp-entra-nle-client-secret"]
}

data "aws_secretsmanager_secret_version" "entra_nle_client_secret" {
  secret_id = data.aws_secretsmanager_secret.entra_nle_client_secret.id
}

data "aws_secretsmanager_secret" "entra_nle_tenant_id" {
  name = module.cis_pp_entra_nle_tenant_id.secret_names["cis-pp-entra-nle-tenant-id"]
}

data "aws_secretsmanager_secret_version" "entra_nle_tenant_id" {
  secret_id = data.aws_secretsmanager_secret.entra_nle_tenant_id.id
}

resource "aws_cognito_identity_provider" "entra" {
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "EntraID"
  provider_type = "OIDC"

  provider_details = {
    client_id                 = jsondecode(data.aws_secretsmanager_secret_version.entra_nle_client_id.secret_string)["CIS_PP_ENTRA_NLE_CLIENT_ID"]
    client_secret             = jsondecode(data.aws_secretsmanager_secret_version.entra_nle_client_secret.secret_string)["CIS_PP_ENTRA_CLIENT_SECRET"]
    authorize_scopes          = "openid email profile"
    attributes_request_method = "GET"
    oidc_issuer               = "https://login.microsoftonline.com/${jsondecode(data.aws_secretsmanager_secret_version.entra_nle_tenant_id.secret_string)["CIS_PP_ENTRA_NLE_TENANT_ID"]}/v2.0"
  }

  attribute_mapping = {
    email    = "email"
    cis-role = "cis-role"
  }
}