
module "irsa" {
  # always replace with latest version from Github
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  namespace            = var.namespace
  role_policy_arns = {
    s3 = module.s3_bucket.irsa_policy_arn
    # ADDED: grants this pod the right to assume the Comprehend role
    # that the Analytical Platform team will create in their AWS account.
    comprehend    = aws_iam_policy.comprehend_assume.arn
    sqs           = module.redact_task_queue.irsa_policy_arn
    redaction_sqs = module.apply_redactions_queue.irsa_policy_arn
    ecr           = module.ecr.irsa_policy_arn
    inspector     = aws_iam_policy.inspector_scan_policy.arn # added to allow the pod to read Inspector scan findings for ECR
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

# ---------------------------------------------------------------------------
# ADDED: IAM policy that allows the pod to assume the cross-account role in
# the Analytical Platform account that grants AWS Comprehend access.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "comprehend_assume" {
  statement {
    sid     = "AllowAssumeComprehendRoleInAP"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::593291632749:role/alpha_app_justice-redact-backend"
    ]
  }
}

resource "aws_iam_policy" "comprehend_assume" {
  name   = "${var.namespace}-comprehend-assume"
  policy = data.aws_iam_policy_document.comprehend_assume.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

# ---------------------------------------------------------------------------
# UNCOMMENTED AND FIXED: exposes the IRSA role name and service account name
# as a Kubernetes secret.
#
# Original had wrong attribute references:
#   role_name        -> aws_iam_role_name  (correct output from module v2.x)
#   service_account.name -> service_account_name (correct output from module v2.x)
# ---------------------------------------------------------------------------
resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.team_name}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_arn
    serviceaccount = module.irsa.service_account.name
  }
}

# ---------------------------------------------------------------------------
# ADDED: service pod for running AWS CLI commands (e.g. aws ecr
# describe-image-scan-findings) against resources this namespace's IRSA
# role has access to.
# ---------------------------------------------------------------------------

module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.1" # check for latest release

  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
}