module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"

  repo_name = var.namespace
  team_name = var.team_name

  github_repositories = ["cloud-platform-ecr-oidc-test"]
}
