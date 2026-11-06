data "aws_caller_identity" "current" {}

module "frontend_ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  repo_name              = "${var.namespace}-frontend"
  github_repositories    = []
  github_environments    = []
  oidc_providers         = []
  deletion_protection    = true
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "backend_ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.2"

  repo_name              = "${var.namespace}-backend"
  github_repositories    = []
  github_environments    = []
  oidc_providers         = []
  deletion_protection    = true
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "ppud_image_publisher_trust" {
  statement {
    sid     = "JusticeAIUnitProductionEnvironment"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:JusticeAIUnit/ppudreplacement:environment:cloud-platform-prod",
        "repo:JusticeAIUnit@215010991/ppudreplacement@1321823112:environment:cloud-platform-prod",
      ]
    }
  }
}

resource "aws_iam_role" "ppud_image_publisher" {
  name               = "${var.namespace}-image-publisher"
  assume_role_policy = data.aws_iam_policy_document.ppud_image_publisher_trust.json

  tags = {
    business-unit = var.business_unit
    application   = var.application
    is-production = var.is_production
    owner         = var.team_name
    namespace     = var.namespace
  }
}

data "aws_iam_policy_document" "ppud_image_publisher" {
  statement {
    sid       = "AuthenticateToECR"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PublishOnlyNamespaceImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      module.frontend_ecr.repo_arn,
      module.backend_ecr.repo_arn,
    ]
  }
}

resource "aws_iam_role_policy" "ppud_image_publisher" {
  name   = "${var.namespace}-image-publisher"
  role   = aws_iam_role.ppud_image_publisher.id
  policy = data.aws_iam_policy_document.ppud_image_publisher.json
}

output "ppud_image_publisher_role_arn" {
  description = "Role ARN for the protected cloud-platform-prod image publication environment"
  value       = aws_iam_role.ppud_image_publisher.arn
}

output "ppud_image_registry" {
  description = "ECR registry for the namespace-owned image repositories"
  value       = split("/", module.frontend_ecr.repo_url)[0]
}

output "ppud_frontend_image_repository" {
  description = "Frontend ECR repository URL"
  value       = module.frontend_ecr.repo_url
}

output "ppud_backend_image_repository" {
  description = "Backend ECR repository URL"
  value       = module.backend_ecr.repo_url
}
