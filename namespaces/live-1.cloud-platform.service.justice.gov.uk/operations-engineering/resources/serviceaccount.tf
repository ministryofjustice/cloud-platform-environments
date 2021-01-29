module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.2"

  namespace = var.namespace

  github_repositories = ["operations-engineering-reports"]
}
