resource "aws_cognito_resource_server" "ats_resource_server" {
  identifier = var.ats_resource_server_identifier
  name       = var.ats_resource_server_name

  scope {
    scope_name        = var.ats_scope_name
    scope_description = var.ats_scope_description
  }
  user_pool_id = aws_cognito_user_pool.ats_user_pool.id
}