locals {
  circleci_sa_name = "circleci-terraform-formbuilder-saas-test"
}

module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  serviceaccount_name = locals.circleci_sa_name

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["fb-editor", "fb-metadata-api", "fb-av"]
}
