module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # Repository configuration
  repo_name = "${var.team_name}/${var.namespace}"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["justice-redact-frontend", "justice-redact-backend"]

  # Scope ECR secrets and variables to the 'dev' GitHub environment
  # This prevents conflicts with staging/prod ECR terraform writing the same repo-level secrets
  github_environments = ["dev"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  enable_irsa = true
}

# Policy allowing Inspector & ECR scan findings read access
resource "aws_iam_policy" "inspector_scan_policy" {
  name        = "${var.namespace}-inspector-scan-policy"
  description = "Allow service pod to read Inspector scan findings for ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowInspectorScanRead"
        Effect = "Allow"
        Action = [
          "ecr:DescribeImageScanFindings",
          "inspector2:ListCoverage",
          "inspector2:ListFindings",
          "inspector2:GetFindingsReportStatus"
        ]
        Resource = "*"
      }
    ]
  })
}