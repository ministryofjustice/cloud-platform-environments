
module "cccd_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"
  repo_name = "cccd"
  team_name = "laa-get-paid"

  providers = {
    aws = aws.london
  }

  oidc_providers      = ["circleci"]
  github_repositories = ["Claim-for-Crown-Court-Defence"]
  namespace           = var.namespace

  lifecycle_policy = <<EOF
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep the newest 10 production images and mark the rest for expiration",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["app-latest"],
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire untagged images older than 1 day",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
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

resource "kubernetes_secret" "cccd_ecr_credentials" {
  metadata {
    name      = "cccd-ecr-credentials-output"
    namespace = "cccd-dev"
  }

  data = {
    access_key_id     = module.cccd_ecr_credentials.access_key_id
    secret_access_key = module.cccd_ecr_credentials.secret_access_key
    repo_arn          = module.cccd_ecr_credentials.repo_arn
    repo_url          = module.cccd_ecr_credentials.repo_url
  }
}
