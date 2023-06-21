resource "aws_cognito_resource_server" "hardship_resource_server" {
  identifier = var.hardship_resource_server_identifier
  name       = var.hardship_resource_server_name

  scope {
    scope_name        = var.hardship_scope_name
    scope_description = var.hardship_scope_description
  }
  user_pool_id = aws_cognito_user_pool.pool.id
}