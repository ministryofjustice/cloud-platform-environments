module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.5"

  namespace           = var.namespace
  github_repositories = ["helloworld-poornima-dev"]
  github_actions_secret_kube_namespace = "KUBE_PROD_NAMESPACE"
  github_actions_secret_kube_cert      = "KUBE_PROD_CERT"
  github_actions_secret_kube_token     = "KUBE_PROD_TOKEN"
  github_actions_secret_kube_cluster   = "KUBE_PROD_CLUSTER"
    # Uncomment and provide repository names to create github actions secrets
    # containing the ca.crt and token for use in github actions CI/CD pipelines
  }
}