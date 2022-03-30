resource "github_actions_secret" "prototype" {
  repository      = var.namespace
  secret_name     = "PROTOTYPE_NAME"
  plaintext_value = var.namespace
}