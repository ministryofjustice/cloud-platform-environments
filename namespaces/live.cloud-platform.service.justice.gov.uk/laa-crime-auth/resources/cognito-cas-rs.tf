resource "aws_cognito_resource_server" "cas_resource_server" {
  identifier = var.cas_resource_server_identifier
  name       = var.cas_resource_server_name

  scope {
    scope_name        = var.cas_scope_name
    scope_description = var.cas_scope_description
  }
  user_pool_id = aws_cognito_user_pool.cas_user_pool.id
}