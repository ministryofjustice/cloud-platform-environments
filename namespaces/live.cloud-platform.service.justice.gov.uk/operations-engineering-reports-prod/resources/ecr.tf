module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  # set this if you use one GitHub repository to push to multiple container repositories
  # this ensures the variable key used in the workflow is unique
  github_actions_prefix = "production"

  oidc_providers                       = ["github"]
  github_repositories                  = ["operations-engineering-reports"]
  github_actions_secret_ecr_name       = "PROD_ECR_NAME"
  github_actions_secret_ecr_url        = "PROD_ECR_URL"
  github_actions_secret_ecr_access_key = "PROD_ECR_ACCESS_KEY"
  github_actions_secret_ecr_secret_key = "PROD_ECR_SECRET_KEY"

  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 30 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

