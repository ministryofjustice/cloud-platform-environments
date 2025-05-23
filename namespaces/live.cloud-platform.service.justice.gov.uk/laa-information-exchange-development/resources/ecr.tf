/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  # REQUIRED: Repository configuration
  repo_name = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["github"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories = ["laa-infoX-application"]

  # OPTIONAL: GitHub environments, to create variables as actions variables in your environments
  # github_environments = ["production"]

  # Lifecycle policies
  # Uncomment the below to automatically tidy up old Docker images
  lifecycle_policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Only keep latest 15 images",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 15
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

  # Tags (commented out until release)
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "laa-aws-infrastructure" # also used for naming the container repository; this is temp set to LAA Ops so ECR won't be recreated
  namespace              = var.namespace            # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
