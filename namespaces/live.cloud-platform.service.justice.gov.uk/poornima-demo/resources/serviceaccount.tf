module "serviceaccount-live" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.5"

  namespace = var.namespace

  # This is needed so the secrets are pushed to the repo in seperate name
  github_actions_secret_kube_cert  = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token = var.github_actions_secret_kube_token

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["helloworld-poornima-dev"]
}

