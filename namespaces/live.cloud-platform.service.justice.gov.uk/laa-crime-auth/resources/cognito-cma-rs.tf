resource "aws_cognito_resource_server" "cma_resource_server" {
  identifier = var.cma_resource_server_identifier
  name       = var.cma_resource_server_name

  scope {
    scope_name        = var.cma_scope_name
    scope_description = var.cma_scope_description
  }
  user_pool_id = aws_cognito_user_pool.cma_user_pool.id
}