/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  repo_name = var.namespace

  # OpenID Connect configuration
  oidc_providers      = ["circleci"]
  github_repositories = ["nsm-e2e-test", "laa-crime-application-store", "laa-submit-crime-forms", "laa-assess-crime-forms"]

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

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr.repo_arn
    repo_url = module.ecr.repo_url
  }
}
