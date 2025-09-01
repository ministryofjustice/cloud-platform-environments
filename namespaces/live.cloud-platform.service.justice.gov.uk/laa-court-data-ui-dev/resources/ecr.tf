module "lcdui_ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  repo_name = var.repo_name

  oidc_providers      = ["circleci"]
  github_repositories = ["laa-court-data-ui", "laa-court-data-adaptor", "hmcts-common-platform-mock-api", "laa-court-data-ui-e2e-tests"]

  # Tags
  business_unit = var.business_unit
  application   = var.application
  is_production = var.is_production
  # TODO: revert to var.team_name when we're ready to move to the new repository
  team_name              = "laa-assess-a-claim" # also used for naming the container repository
  namespace              = var.namespace        # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }

  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep the newest 10 production images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["main-"],
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep branch images for 60 days",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["branch-"],
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
}

resource "kubernetes_secret" "lcdui_ecr_credentials" {
  metadata {
    name      = "lcdui-ecr-credentials"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.lcdui_ecr_credentials.repo_arn
    repo_url = module.lcdui_ecr_credentials.repo_url
  }
}
