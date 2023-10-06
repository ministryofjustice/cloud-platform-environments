resource "aws_cognito_resource_server" "orchestration_resource_server" {
  identifier = var.orchestration_resource_server_identifier
  name       = var.orchestration_resource_server_name

  scope {
    scope_name        = var.orchestration_scope_name
    scope_description = var.orchestration_scope_description
  }
  user_pool_id = aws_cognito_user_pool.orchestration_user_pool.id
}