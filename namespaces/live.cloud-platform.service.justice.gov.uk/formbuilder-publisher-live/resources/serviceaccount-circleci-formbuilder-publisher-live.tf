module "serviceaccount_circleci-formbuilder-publisher-live" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  serviceaccount_name = "circleci-formbuilder-publisher-live-migrated"
  role_name = "circleci-formbuilder-publisher-live-migrated"
  rolebinding_name = "circleci-formbuilder-publisher-live-migrated"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  # github_repositories = ["my-repo"]
}

