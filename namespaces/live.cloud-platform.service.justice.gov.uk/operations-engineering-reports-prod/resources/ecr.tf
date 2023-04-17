module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

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

