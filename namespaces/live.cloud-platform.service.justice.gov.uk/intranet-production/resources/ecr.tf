/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "intranet_ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.0.0"

  repo_name = "intranet-ecr" # Arbitrary module name does not need to reference any existing modules

  # enable the oidc implementation for GitHub
  oidc_providers = ["github"]

  # specify which GitHub repository you're pushing from
  github_repositories = [var.app_repo]

  # Lifecycle policies
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
            "tagStatus": "tagged",
            "countType": "imageCountMoreThan",
            "countNumber": 100,
            "tagPrefixList": ["production"]
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
    EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
