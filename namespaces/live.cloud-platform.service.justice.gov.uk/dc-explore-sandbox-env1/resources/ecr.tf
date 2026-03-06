module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  repo_name = var.namespace

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = [var.github_repository_name]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  lifecycle_policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1, "description": "Expire untagged images older than 10 days",
          "selection": { "tagStatus": "untagged", "countType": "sinceImagePushed", "countUnit": "days", "countNumber": 10 },
          "action": { "type": "expire" }
        },
        {
          "rulePriority": 2, "description": "Keep last 50 release images",
          "selection": { "tagStatus": "tagged", "tagPrefixList": ["v"], "countType": "imageCountMoreThan", "countNumber": 50 },
          "action": { "type": "expire" }
        },
        {
          "rulePriority": 3, "description": "Keep the newest 100 images and mark the rest for expiration",
          "selection": { "tagStatus": "any", "countType": "imageCountMoreThan", "countNumber": 100 },
          "action": { "type": "expire" }
        }
      ]
    }
    EOF

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for read only queries,
  # uncomment below:

  # enable_irsa = true
}
