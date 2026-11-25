module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.1"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # Creates GitHub Actions secrets containing the ca.crt and token for CI/CD pipelines
  github_repositories = ["laa-ai-document-parser-api"]
  github_environments = ["dev"]
}
