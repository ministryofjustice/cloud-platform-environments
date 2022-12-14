
module "github-prototype" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-github-prototype?ref=0.1.1"

  namespace = var.namespace
}

resource "github_actions_secret" "prototype" {
  repository      = var.namespace
  secret_name     = "PROTOTYPE_NAME"
  plaintext_value = var.namespace
}
