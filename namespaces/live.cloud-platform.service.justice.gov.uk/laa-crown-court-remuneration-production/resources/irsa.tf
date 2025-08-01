module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    sqs_ccr_claims = aws_iam_policy.ccr_policy_prod.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "ccr_claims_policy_prod" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    sid  = "CCRPolicySQSPROD"
    effect = "Allow"
    actions = [
      "sqs:*",
      "sts:*"
    ]
    resources = [
      "arn:aws:sqs:eu-west-2:754256621582:laa-get-paid-production-cccd-claims-for-ccr",
      "arn:aws:sqs:eu-west-2:754256621582:laa-get-paid-production-cccd-claims-submitted-ccr-dlq",
      "arn:aws:sqs:eu-west-2:754256621582:laa-get-paid-production-responses-for-cccd",
      "arn:aws:sqs:eu-west-2:754256621582:laa-get-paid-production-reponses-for-cccd-dlq",
    ]
  }

}

resource "aws_iam_policy" "ccr_policy_prod" {
  name        = "ccr_policy_prod"
  policy      = data.aws_iam_policy_document.ccr_claims_policy_prod  .json
  description = "Policy for Cloud Platform to assume role in PROD account for CCR"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.team_name}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name

    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}
