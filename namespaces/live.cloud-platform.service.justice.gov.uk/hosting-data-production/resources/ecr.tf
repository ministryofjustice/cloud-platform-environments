module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"

  repo_name = "hosting-data"
  team_name = var.team_name

  github_actions_prefix = "prod"
  github_repositories   = ["hosting-data"]
  oidc_providers        = ["github"]
}
