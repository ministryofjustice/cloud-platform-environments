module "cla_frontend_app_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.4"

  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cla_frontend_app_credentials" {
  metadata {
    name      = "ecr-repo-laa-cla-frontend"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.cla_frontend_app_credentials.repo_url
    access_key_id     = module.cla_frontend_app_credentials.access_key_id
    secret_access_key = module.cla_frontend_app_credentials.secret_access_key
  }
}

module "cla_frontend_socket_server_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.4"

  team_name = var.team_name
  repo_name = "cla_frontend_socket_server"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cla_frontend_socket_server_credentials" {
  metadata {
    name      = "ecr-repo-laa-cla-frontend-socket-server"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.cla_frontend_socket_server_credentials.repo_url
    access_key_id     = module.cla_frontend_socket_server_credentials.access_key_id
    secret_access_key = module.cla_frontend_socket_server_credentials.secret_access_key
  }
}
