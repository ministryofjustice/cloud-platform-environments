# TODO: delete "ecr-repo-applyforlegalaid-service" module once images
# being pushed/pulled to/from new ECR repo
module "ecr-repo-applyforlegalaid-service" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name = var.team_name
  repo_name = "applyforlegalaid-service"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-applyforlegalaid-service" {
  metadata {
    name      = "ecr-repo-applyforlegalaid-service"
    namespace = var.namespace
  }

  data = {
    repo_arn          = module.ecr-repo-applyforlegalaid-service.repo_arn
    repo_url          = module.ecr-repo-applyforlegalaid-service.repo_url
    access_key_id     = module.ecr-repo-applyforlegalaid-service.access_key_id
    secret_access_key = module.ecr-repo-applyforlegalaid-service.secret_access_key
  }
}

module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name           = var.team_name
  repo_name           = "${var.namespace}-ecr"
  oidc_providers      = ["circleci"]
  github_repositories = [var.repo_name]
  namespace           = var.namespace

  providers = {
    aws = aws.london
  }

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
                "countNumber": 50
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn          = module.ecr_credentials.repo_arn
    repo_url          = module.ecr_credentials.repo_url
    access_key_id     = module.ecr_credentials.access_key_id
    secret_access_key = module.ecr_credentials.secret_access_key
  }
}

module "ecr-repo-clamav" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name = "laa-apply-for-legal-aid"
  repo_name = "clamav"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-clamav" {
  metadata {
    name      = "ecr-repo-clamav"
    namespace = "laa-apply-for-legalaid-production"
  }

  data = {
    repo_arn          = module.ecr-repo-clamav.repo_arn
    repo_url          = module.ecr-repo-clamav.repo_url
    access_key_id     = module.ecr-repo-clamav.access_key_id
    secret_access_key = module.ecr-repo-clamav.secret_access_key
  }
}

