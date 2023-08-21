resource "aws_cognito_resource_server" "ccp_resource_server" {
  identifier = var.ccp_resource_server_identifier
  name       = var.ccp_resource_server_name

  scope {
    scope_name        = var.ccp_scope_name
    scope_description = var.ccp_scope_description
  }
  user_pool_id = aws_cognito_user_pool.ccp_user_pool.id
}