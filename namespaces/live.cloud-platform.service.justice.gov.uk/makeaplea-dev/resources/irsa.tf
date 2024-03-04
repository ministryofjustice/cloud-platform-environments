# data "aws_iam_policy_document" "s3_policy_doc" {
#   statement {
#     actions = [
#       "s3:PutObject",
#       "s3:ListBucket",
#       "s3:GetObject*",
#     ]
#     resources = [
#       module.s3_bucket.bucket_arn,
#       "${module.s3_bucket.bucket_arn}/*"
#     ]
#   }
# }

# resource "aws_iam_policy" "s3_policy" {
#   name        = "irsa-access-to-s3-bucket"
#   path        = "/cloud-platform/"
#   policy      = data.aws_iam_policy_document.s3_policy_doc.json
# }

data "aws_iam_policy_document" "sqs_policy_doc" {
  statement {
    actions = [
      "sqs:*",
    ]
    resources = [
        "*",
    ]
  }
}

resource "aws_iam_policy" "sqs_policy" {
  name        = "irsa-access-to-sqs"
  path        = "/cloud-platform/"
  policy      = data.aws_iam_policy_document.sqs_policy_doc.json
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "makeaplea-dev"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    # s3                        = aws_iam_policy.s3_policy.arn
    sqs_map_queue             = aws_iam_policy.sqs_policy.arn
    sqs_map_queue_dead_letter = module.makeaplea_dead_letter_queue.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
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