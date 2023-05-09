module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.4"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  github_repositories                  = ["operations-engineering-reports"]
  github_actions_secret_ecr_name       = "DEV_ECR_NAME"
  github_actions_secret_ecr_url        = "DEV_ECR_URL"
  github_actions_secret_ecr_access_key = "DEV_ECR_ACCESS_KEY"
  github_actions_secret_ecr_secret_key = "DEV_ECR_SECRET_KEY"

  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-repo.repo_url
    access_key_id     = module.ecr-repo.access_key_id
    secret_access_key = module.ecr-repo.secret_access_key
  }
}

