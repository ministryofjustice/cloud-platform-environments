/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "intranet_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"
  repo_name = "intranet-ecr" # Arbitrary module name does not need to reference any existing modules
  team_name = var.team_name    # Github team name

  providers = {
    aws = aws.london
  }
  github_repositories = [var.repo_name]

  # enable the oidc implementation for GitHub
  oidc_providers = ["github"]

  # specify which GitHub repository you're pushing from
  github_repositories = [var.app_repo]

 # Lifecycle policies
  # Uncomment the below to automatically tidy up old Docker images
  lifecycle_policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Expire untagged images older than 14 days",
          "selection": {
            "tagStatus": "untagged",
            "countType": "sinceImagePushed",
            "countUnit": "days",
            "countNumber": 14
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 2,
          "description": "Keep last 30 dev and staging images",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["dev", "staging"],
            "countType": "imageCountMoreThan",
            "countNumber": 30
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 3,
          "description": "Keep the newest 100 images and mark the rest for expiration",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 100,
            "tagPrefixList": ["production"],
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
    EOF
}
/*
resource "kubernetes_secret" "intranet_ecr_credentials" {
  metadata {
    name      = "intranet-ecr-credentials-output"
    namespace = "intranet-production"
  }

  data = {
    access_key_id     = module.intranet_ecr_credentials.access_key_id
    secret_access_key = module.intranet_ecr_credentials.secret_access_key
    repo_arn          = module.intranet_ecr_credentials.repo_arn
    repo_url          = module.intranet_ecr_credentials.repo_url
  }
}*/