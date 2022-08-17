module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.4"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["analytical-platform-uploader"]

  # list of github environments, to create the service account secrets as environment secrets
  # https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets
  github_environments = ["preprod"]
}
