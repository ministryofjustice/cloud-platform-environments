resource "aws_cognito_resource_server" "ccc_resource_server" {
  identifier = var.ccc_resource_server_identifier
  name       = var.ccc_resource_server_name

  scope {
    scope_name        = var.ccc_scope_name
    scope_description = var.ccc_scope_description
  }
  user_pool_id = aws_cognito_user_pool.ccc_user_pool.id
}