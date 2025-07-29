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
    sqs_cclf_claims = aws_iam_policy.cclf_policy_uat.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "cclf_claims_policy" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    sid  = "CCLFPolicySQSUAT"
    effect = "Allow"
    actions = [
      "sqs:*",
      "sts:*"
    ]
    resources = [
      "arn:aws:sqs:eu-west-2:754256621582:laa-get-paid-dev-lgfs-cccd-claims-for-cclf",
      "arn:aws:sqs:eu-west-2:754256621582:laa-get-paid-dev-lgfs-cccd-claims-submitted-cclf-dlq",
      "arn:aws:sqs:eu-west-2:754256621582:laa-get-paid-dev-lgfs-responses-for-cccd",
      "arn:aws:sqs:eu-west-2:754256621582:laa-get-paid-dev-lgfs-reponses-for-cccd-dlq",
    ]
  }

}

resource "aws_iam_policy" "cclf_policy_uat" {
  name        = "cclf_policy_uat"
  policy      = data.aws_iam_policy_document.cclf_claims_policy.json
  description = "Policy for Cloud Platform to assume role in UAT account for CCLF"

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
