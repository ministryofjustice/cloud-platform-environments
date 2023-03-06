
# This module creates files to build docker image and 
# continuous deployment (CD) workflow in prototype github repo.

resource "github_actions_secret" "prototype" {
  repository      = var.namespace
  secret_name     = "PROTOTYPE_NAME"
  plaintext_value = var.namespace
}
