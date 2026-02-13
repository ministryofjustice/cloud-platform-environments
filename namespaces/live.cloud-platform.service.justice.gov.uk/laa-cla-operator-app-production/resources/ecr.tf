/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  team_name = var.team_name

  # ECR Repository configuration
  repo_name = "laa-cla-operator-app-ecr"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["laa-cla-operator-app"]

  # Production images are tagged with "main". Other images are tagged "branch".
  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep the newest 1000 UAT images (100 branches, 10 commits on each)",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["branch"],
                "countType": "imageCountMoreThan",
                "countNumber": 1000
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep the newest 100 production images and mark the rest for expiration",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["main"],
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

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for read only queries,
  # uncomment below:

  # enable_irsa = true
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-laa-cla-operator-app"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr_credentials.repo_arn
    repo_url = module.ecr_credentials.repo_url
  }
}
