/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # REQUIRED: Repository configuration
  repo_name = var.namespace

  # REQUIRED: OIDC providers to configure, either "github", "circleci", or both
  oidc_providers = ["circleci", "github"]

  # REQUIRED: GitHub repositories that push to this container repository
  github_repositories   = ["laa-crime-application-store", "nsm-e2e-test"]

  # OPTIONAL: GitHub environments, to create variables as actions variables in your environments
  # github_environments = ["production"]

  # Lifecycle_policy provides a way to automate the cleaning up of your container images by expiring images based on age or count.
  # To apply multiple rules, combined them in one policy JSON.
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html

  lifecycle_policy = <<EOF
  {
      "rules": [
          {
              "rulePriority": 1,
              "description": "Expire images older than 60 days",
              "selection": {
                  "tagStatus": "any",
                  "countType": "sinceImagePushed",
                  "countUnit": "days",
                  "countNumber": 60
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
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
