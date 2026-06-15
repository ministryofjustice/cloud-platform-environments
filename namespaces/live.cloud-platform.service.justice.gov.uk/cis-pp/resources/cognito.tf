# =============================================================================
# Auth Module - Cognito User Pool & Amplify
# =============================================================================

# -----------------------------------------------------------------------------
# Cognito User Pool
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

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
    email_sending_account = "DEVELOPER"
    source_arn            = aws_sesv2_email_identity.main.arn
    from_email_address    = "noreply@${var.ses_domain}"
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

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  tags = merge({
    Name = "${var.environment}-${var.aws_region}-user-pool"
  }, local.common_tags)
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

  supported_identity_providers = ["COGNITO"]

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
}