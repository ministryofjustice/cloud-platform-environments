module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = ["hmpps-person-match"]
  github_environments = ["dev"]

  serviceaccount_name = "github-actions-serviceaccount"
  role_name           = "github-actions-serviceaccount-role"
  rolebinding_name    = "github-actions-serviceaccount-rolebinding"
}

data "github_user" "current" {
  # No arguments needed; it will fetch information for the token owner
  username = ""
}

resource "kubernetes_secret" "github_docker_registry" {
  metadata {
    name = "github-docker-registry-secret"
    namespace = var.namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        var.registry_server = {
          username = data.github_user.current.login
          password = var.github_token
          email    = data.github_user.current.email
          auth     = base64encode("${data.github_user.current.login}:${var.github_token}")
        }
      }
    })
  }
}