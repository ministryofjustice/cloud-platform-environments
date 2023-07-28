/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "contact-moj_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"
  repo_name = "contact-moj-ecr"
  team_name = var.team_name
  namespace = var.namespace
  providers = {
    aws = aws.london
  }

  oidc_providers = ["circleci"]
  github_repositories = [var.repo_name]

  lifecycle_policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
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

resource "kubernetes_secret" "contact-moj_ecr_credentials" {
  metadata {
    name      = "contact-moj-ecr-credentials-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.contact-moj_ecr_credentials.access_key_id
    secret_access_key = module.contact-moj_ecr_credentials.secret_access_key
    repo_arn          = module.contact-moj_ecr_credentials.repo_arn
    repo_url          = module.contact-moj_ecr_credentials.repo_url
  }
}
