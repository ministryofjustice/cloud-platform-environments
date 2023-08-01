# Cognito test for Inranet

/*variable "region" {
  default = "eu-west-1"
}

provider "aws" {
  region = "${var.region}"
  profile = "terraform-testing"
}
*/

resource "aws_cognito_user_pool" "Azure_AD_Test" {
  name = "Azure-AD-test"
  deletion_protection = "INACTIVE"

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  tags = {
    Name = "Azure_AD_Test"
  }
}

resource "aws_cognito_user_pool_domain" "Cognito-test-domain" {
  domain       = "javauth"
  user_pool_id = aws_cognito_user_pool.Azure_AD_Test.id
}

resource "aws_cognito_identity_provider" "Azure_IDP" {
  user_pool_id  = aws_cognito_user_pool.Azure_AD_Test.id
  provider_name = "azure-active-directory-idp"
  provider_type = "SAML"

  provider_details = {
    MetadataURL = "https://login.microsoftonline.com/f9b7342c-cf74-4689-8660-a45127206763/federationmetadata/2007-06/federationmetadata.xml?appid=b65cfc9f-42f7-4438-aecc-5259ad77bcdd"
  }

  attribute_mapping = {
    email    = "emailaddress"
    family_name = "surname"
    given_name = "givenname"
    name = "name"
  }
}

resource "aws_cognito_user_pool_client" "Azure_Client" {
  name = "Azure_Client"
  user_pool_id = aws_cognito_user_pool.Azure_AD_Test.id
  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH","ALLOW_USER_SRP_AUTH"]
  supported_identity_providers = ["azure-active-directory-idp"]
  callback_urls = ["https://jwt.io"]
  prevent_user_existence_errors = "ENABLED"
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes  = ["openid","profile"]
  allowed_oauth_flows = ["code"]
}