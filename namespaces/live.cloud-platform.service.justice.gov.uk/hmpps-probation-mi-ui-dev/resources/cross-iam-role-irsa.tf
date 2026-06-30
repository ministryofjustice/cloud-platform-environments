locals {
  dpr_data_api_role = "dpr-data-api-cross-account-role"

  accounts_map = {
    development = "771283872747",
    test        = "203591025782",
    preprod     = "972272129531",
    prod        = "004723187462"
  }

  environments_map = {
    development = "development",
    test        = "test",
    preprod     = "preproduction",
    prod        = "production"
  }

  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }

  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

module "dpr_mi_assume_role" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                        = "5.13.0"
  create_role                    = true
  role_name                      = "dpr-reporting-probation-mi-${var.environment}-cross-iam-${var.eks_cluster_name}"
  provider_url                   = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  role_policy_arns               = [aws_iam_policy.cross_iam_dpr_oidc.arn]
  oidc_fully_qualified_subjects  = ["system:serviceaccount:${var.namespace}:dpr-reporting-mi-${lookup(local.environments_map, lower(var.environment))}-cross-iam"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
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
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    team-name              = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    owner                  = var.owner
    service-area           = var.service_area
  }
}

module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "dpr-reporting-mi-${var.environment}-cross-iam"
  namespace            = var.namespace
  role_policy_arns = merge(
    {
      secrets = aws_iam_policy.cross_iam_policy_mp.arn
    },
    {
      sqs = module.hmpps_probation_mi_domain_events_queue.irsa_policy_arn
    },
    {
      sqs_dlq = module.hmpps_probation_mi_domain_events_dlq.irsa_policy_arn
    },
    local.sns_policies
  )

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0" # use the latest release

  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
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
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    team-name              = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    owner                  = var.owner
    service-area           = var.service_area
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}

