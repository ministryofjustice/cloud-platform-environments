module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "fraud-and-corruption-insights-dev-sa"
  namespace            = var.namespace

  role_policy_arns = {
    dynamodb                = module.dynamodb-cluster.irsa_policy_arn
    dynamodb_dev            = module.dynamodb-fci-dev.irsa_policy_arn
    xaccounts3              = aws_iam_policy.access_ap_s3_policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0" 
  
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}

data "aws_iam_policy_document" "access_ap_s3_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::593291632749:role/alpha_app_fraud-and-corruption-insights"
    ]
  }
}

resource "aws_iam_policy" "access_ap_s3_policy" {
  name   = "${var.namespace}-access-ap-s3-policy"
  policy = data.aws_iam_policy_document.access_ap_s3_policy.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}
