module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name           = var.team_name
  repo_name           = "${var.namespace}-ecr"
  oidc_providers      = ["circleci"]
  github_repositories = [var.repo_name]
  namespace           = var.namespace

  /*
  # Lifecycle_policy provides a way to automate the cleaning up of your container images by expiring images based on age or count.
  # To apply multiple rules, combined them in one policy JSON.
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html
  */
  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than 7 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire images tagged with 'latest' older than 180 days",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["latest"],
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 180
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 3,
            "description": "Keep the newest 50 images and mark the rest for expiration",
            "selection": {
                "tagStatus": "any",
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
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_url          = module.ecr-repo.repo_url
    access_key_id     = module.ecr-repo.access_key_id
    secret_access_key = module.ecr-repo.secret_access_key
  }
}
