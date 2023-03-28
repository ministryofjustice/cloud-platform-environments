resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name
}

resource "aws_cognito_user_pool_client" "client" {
  name                  = var.cognito_user_pool_client_name
<<<<<<< HEAD
  user_pool_id          = aws_cognito_user_pool.pool.id
=======
  user_pool_id          = "${aws_cognito_user_pool.pool.id}"
>>>>>>> 93439a167cb3b1f9a1594ea9a47c68bc465ca887
  explicit_auth_flows   = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows   = ["client_credentials"]
  generate_secret       = true
}

resource "aws_cognito_resource_server" "resource" {
  identifier = var.resource_server_identifier
  name       = var.resource_server_name

  scope {
    scope_name        = var.resource_server_scope_name
    scope_description = var.resource_server_scope_description
  }

<<<<<<< HEAD
  user_pool_id = aws_cognito_user_pool.pool.id
=======
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
>>>>>>> 93439a167cb3b1f9a1594ea9a47c68bc465ca887
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain          = var.cognito_user_pool_domain_name
  user_pool_id    = aws_cognito_user_pool.pool.id
}