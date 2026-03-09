# ECR Credentials for GitHub Actions to push Docker images
module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # ECR Repository name
  repo_name = "laa-generic-app"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = false
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

# Store ECR credentials as Kubernetes secret for pod image pulls
resource "kubernetes_secret" "ecr_pull_secret" {
  metadata {
    name      = "ecr-pull-secret"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "ecr-credentials"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  type = "kubernetes.io/dockercfg"

  data = {
    ".dockercfg" = base64encode(jsonencode({
      (module.ecr_credentials.registry_url) = {
        "username" = "AWS"
        "password" = module.ecr_credentials.secret_access_key
        "email"    = "no-reply@justice.gov.uk"
      }
    }))
  }

  depends_on = [
    module.ecr_credentials
  ]
}

# Output ECR credentials for GitHub Actions
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr_credentials.registry_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr_credentials.repository_arn
}

output "ecr_access_key_id" {
  description = "Access key ID for ECR push"
  sensitive   = true
  value       = module.ecr_credentials.access_key_id
}

output "ecr_secret_access_key" {
  description = "Secret access key for ECR push"
  sensitive   = true
  value       = module.ecr_credentials.secret_access_key
}
