resource "aws_cognito_resource_server" "mst_resource_server" {
  identifier = var.mst_resource_server_identifier
  name       = var.mst_resource_server_name

  scope {
    scope_name        = var.mst_scope_name
    scope_description = var.mst_scope_description
  }
  user_pool_id = aws_cognito_user_pool.mst_user_pool.id
}