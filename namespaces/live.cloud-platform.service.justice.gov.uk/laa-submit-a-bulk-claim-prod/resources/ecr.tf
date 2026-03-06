/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # REQUIRED: Repository configuration
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"
  namespace = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["github"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["laa-submit-a-bulk-claim"]

  # Lifecycle policies
  lifecycle_policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep last 10 prod images",
          "selection": {
            "tagStatus": "tagged",
            "tagPatternList": ["prod*"],
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 2,
          "description": "Keep last 10 stg images",
          "selection": {
            "tagStatus": "tagged",
            "tagPatternList": ["stg*"],
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 3,
          "description": "Keep last 10 uat images",
          "selection": {
            "tagStatus": "tagged",
            "tagPatternList": ["uat*"],
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 4,
          "description": "Keep the newest 100 images",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 100
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
    EOF


  # OPTIONAL: Add deletion_protection = false parameter if you are planning on either deleting your environment namespace or ECR resource.
  # IMPORTANT: It is the PR owners responsibility to ensure that no other environments are sharing this ECR registry.
  # This flag will allow a non-empty ECR to be deleted.
  # Defaults to true

  # deletion_protection = false

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}