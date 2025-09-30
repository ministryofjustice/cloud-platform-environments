# Add the names of the SQS queues & SNS topics which the app needs permissions to access.
# The value of each item should be the namespace where the queue or topic was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  # The names of the queues used and the namespace which created them
  sqs_queues = {
    "Digital-Prison-Services-prod-hmpps_audit_queue" = "hmpps-audit-prod",
  }

  # The names of the SNS topics used and the namespace which created them
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }

  connect_dps_distingishing_marks_s3 = "arn:aws:s3:::cloud-platform-43f9c0552bd867b0ac307686f139b6a1"


  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0" # use the latest release

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hmpps-document-management-api"
  role_policy_arns = merge(local.sqs_policies, local.sns_policies, {
    s3       = module.s3.irsa_policy_arn
    s3images = module.s3-images.irsa_policy_arn
    cross_namespace_s3 = aws_iam_policy.cross_namespace_s3_policy.arn
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

resource "aws_iam_policy" "cross_namespace_s3_policy" {
  name   = "${var.namespace}-cross-namespace-s3-policy"
  policy = data.aws_iam_policy_document.cross_namespace_s3_access.json
}

# IAM policy to allow access to specific S3 buckets in other namespaces.
data "aws_iam_policy_document" "cross_namespace_s3_access" {
  statement {
    sid       = "AllowListAccessToCrossNamespaceS3Buckets"
    actions   = ["s3:ListBucket"]
    resources = [local.connect_dps_distingishing_marks_s3]
  }

  statement {
    sid = "AllowReadWriteAccessToCrossNamespaceS3Buckets"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = ["${local.connect_dps_distingishing_marks_s3}/*", ]
  }
}

data "aws_iam_policy_document" "allow_preprod_irsa_read" {
  statement {
    sid    = "AllowSourceBucketAccess"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::754256621582:role/cloud-platform-irsa-c94f9bbe4f28e0e3-live"]
    }

    resources = [
      module.s3.bucket_arn,
      "${module.s3.bucket_arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_preprod_irsa_read" {
  bucket = module.s3.bucket_name
  policy = data.aws_iam_policy_document.allow_preprod_irsa_read.json
}

data "aws_iam_policy_document" "s3_images_policy" {
  statement {
    sid    = "AllowS3ImagesAccess"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::754256621582:role/cloud-platform-irsa-c94f9bbe4f28e0e3-live"]
    }

    resources = [
      module.s3-images.bucket_arn,
      "${module.s3-images.bucket_arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_preprod_irsa_s3_images" {
  bucket = module.s3-images.bucket_name
  policy = data.aws_iam_policy_document.s3_images_policy.json
}

