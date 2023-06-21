resource "aws_cognito_resource_server" "evidence_resource_server" {
  identifier = var.evidence_resource_server_identifier
  name       = var.evidence_resource_server_name

  scope {
    scope_name        = var.evidence_scope_name
    scope_description = var.evidence_scope_description
  }
  user_pool_id = aws_cognito_user_pool.pool.id
}