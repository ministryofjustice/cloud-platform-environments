module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name = var.team_name
  repo_name = var.repo_name

  github_repositories = [var.repo_name]

  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images keeping newest 200",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 200
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
    name      = "ecr-repo"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-repo.repo_url
    access_key_id     = module.ecr-repo.access_key_id
    secret_access_key = module.ecr-repo.secret_access_key
    repo_arn          = module.ecr-repo.repo_arn
  }
}
