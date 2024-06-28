locals {
  dpr_data_api_role = "dpr-data-api-cross-account-role"

  accounts_map = {
    development = "771283872747",
    test = "203591025782"
  }

  environments_map = {
    development = "development",
    test = "test"
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

# Cluster OIDC
module "dpr_tools_assume_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.13.0"
  create_role                   = true
  role_name                     = "dpr-tools-${var.environment}-cross-iam-${var.eks_cluster_name}"
  provider_url                  = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  role_policy_arns              = [aws_iam_policy.cross_iam_dpr_oidc.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:dpr-tools-${lookup(local.environments_map, lower(var.environment))}-cross-iam"]
  oidc_fully_qualified_audiences= ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "cross_iam_dpr_oidc" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["arn:aws:iam::${lookup(local.accounts_map, lower(var.environment))}:role/${local.dpr_data_api_role}"]
  }
}

resource "aws_iam_policy" "cross_iam_dpr_oidc" {
  name   = "${var.namespace}-cross-iam-dpr-oidc"
  policy = data.aws_iam_policy_document.cross_iam_dpr_oidc.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

# IRSA
module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "dpr-tools-${var.environment}-cross-iam"
  namespace            = var.namespace
  role_policy_arns     = {
    secrets = aws_iam_policy.cross_iam_policy_mp.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "cross_iam_policy_mp" {
  statement {
    actions = [
      "secretsmanager:Get*",
      "secretsmanager:List*",
    ]
    resources = ["arn:aws:secretsmanager:eu-west-2:${lookup(local.accounts_map, lower(var.environment))}:secret:dpr-redshift-secret-*-*"]
  }

  statement {
    actions = [
      "kms:Describe*",
      "kms:Decrypt",
      "kms:Get*",
      "kms:List*",
    ]
    resources = ["arn:aws:kms:eu-west-2:${lookup(local.accounts_map, lower(var.environment))}:key/*"]
  }

  statement {
    actions = [
      "sts:AssumeRole",
    ]
    resources = ["arn:aws:iam::${lookup(local.accounts_map, lower(var.environment))}:role/${local.dpr_data_api_role}"]
  }
}

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

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}