module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "makeaplea-prod"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3                        = module.s3_bucket.irsa_policy_arn
    sqs_map_queue             = module.makeaplea_queue.irsa_policy_arn
    sqs_map_queue_dead_letter = module.makeaplea_dead_letter_queue.irsa_policy_arn
    sqs_assume_role           = aws_iam_policy.assume_role_policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      module.makeaplea_queue.irsa_policy_arn,
    ]
  }
}

resource "aws_iam_policy" "assume_role_policy" {
  name        = "${var.namespace}-assume-role"
  path        = "/${var.namespace}/"
  policy      = data.aws_iam_policy_document.document.json
  description = "Assume role policy for makeaplea sqs queue resource"
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.team_name}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}