module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=oidc"

  repo_name = var.namespace
  team_name = var.team_name

  github_repositories = ["cloud-platform-ecr-oidc-test"]
}

# there is already an oidc provider in CP for GitHub from a firebreak test a while ago, need to remove it when rolling this out for real and create it in -infrastructure
