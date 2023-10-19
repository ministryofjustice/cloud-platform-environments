resource "aws_cognito_resource_server" "validation_resource_server" {
  identifier = var.validation_resource_server_identifier
  name       = var.validation_resource_server_name

  scope {
    scope_name        = var.validation_scope_name
    scope_description = var.validation_scope_description
  }
  user_pool_id = aws_cognito_user_pool.validation_user_pool.id
}