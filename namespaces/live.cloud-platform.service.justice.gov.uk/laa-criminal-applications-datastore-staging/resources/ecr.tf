module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.4"

  team_name = var.team_name
  repo_name = var.repo_name

  github_repositories = [var.repo_name]

  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images keeping newest 25",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 25
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
