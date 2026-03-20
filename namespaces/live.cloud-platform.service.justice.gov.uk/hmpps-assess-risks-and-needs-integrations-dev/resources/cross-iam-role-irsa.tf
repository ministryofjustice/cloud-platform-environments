locals {
  # MP cross-account role name (same as DPR uses)
  mp_cross_account_role = "dpr-data-api-cross-account-role"

  # MP AWS account IDs per environment
  mp_accounts_map = {
    dev     = "771283872747"  # MP development account
    preprod = "972272129531"  # MP preprod account
    prod    = "004723187462"  # MP production account
  }

  # Environment mapping for service account naming
  environments_map = {
    dev     = "development"
    preprod = "preproduction"
    prod    = "production"
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

# IRSA module - creates the role that K8s pods will assume
module "arns_cross_account_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "arns-${var.environment}-cross-iam"
  namespace            = var.namespace
  role_policy_arns     = {
    cross_account = aws_iam_policy.cross_iam_policy_mp.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

# IAM policy document that allows assuming the MP cross-account role
data "aws_iam_policy_document" "cross_iam_policy_mp" {
  # Allow assuming the MP cross-account role
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    resources = ["arn:aws:iam::${lookup(local.mp_accounts_map, lower(var.environment))}:role/${local.mp_cross_account_role}"]
  }

  # Permissions for accessing secrets in MP (if needed directly)
  statement {
    actions = [
      "secretsmanager:Get*",
      "secretsmanager:List*",
    ]
    resources = ["arn:aws:secretsmanager:eu-west-2:${lookup(local.mp_accounts_map, lower(var.environment))}:secret:*"]
  }

  # KMS permissions for decrypting secrets in MP
  statement {
    actions = [
      "kms:Describe*",
      "kms:Decrypt",
      "kms:Get*",
      "kms:List*",
    ]
    resources = ["arn:aws:kms:eu-west-2:${lookup(local.mp_accounts_map, lower(var.environment))}:key/*"]
  }
}

# Create the IAM policy
resource "aws_iam_policy" "cross_iam_policy_mp" {
  name   = "${var.namespace}-cross-iam-role-mp"
  policy = data.aws_iam_policy_document.cross_iam_policy_mp.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

# Create a Kubernetes secret with the IRSA role information
resource "kubernetes_secret" "cross_account_irsa" {
  metadata {
    name      = "arns-cross-account-irsa-output"
    namespace = var.namespace
  }
  data = {
    role                      = module.arns_cross_account_irsa.role_name
    role_arn                  = module.arns_cross_account_irsa.role_arn
    serviceaccount            = module.arns_cross_account_irsa.service_account.name
    mp_cross_account_role_arn = "arn:aws:iam::${lookup(local.mp_accounts_map, lower(var.environment))}:role/${local.mp_cross_account_role}"
  }
}

