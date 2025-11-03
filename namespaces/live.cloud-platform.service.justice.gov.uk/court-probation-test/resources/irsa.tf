locals {
  sqs_queues = {
    "Digital-Prison-Services-dev-pic_probation_offender_events_queue"    = "offender-events-dev"
    "Digital-Prison-Services-dev-pic_probation_offender_events_queue_dl" = "offender-events-dev"
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }

  default_tags = {
    namespace              = var.namespace
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }

  identifier = "${var.application}-${var.environment}"
}

module "court-facing-api-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "court-facing-api"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = merge(
    { s3 = module.crime-portal-gateway-s3-bucket.irsa_policy_arn },
    { s3_large_cases = module.large-court-cases-s3-bucket.irsa_policy_arn },
    { sns_cc = module.court-cases.irsa_policy_arn },
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = var.application
  namespace            = var.namespace # this is also used as a tag

  # Attach the appropriate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = merge(
    local.sns_policies,
    local.sqs_policies,
    { rds_ccs = module.court_case_service_rds.irsa_policy_arn },
    { rds_pss = module.pre_sentence_service_rds.irsa_policy_arn },
    { s3 = module.crime-portal-gateway-s3-bucket.irsa_policy_arn },
    { s3_large_cases = aws_iam_policy.read_only_s3_policy.arn },
    { sqs = aws_iam_policy.combined_prepare_a_case_sqs.arn },
    { s3_cpr = aws_iam_policy.cross_namespace_s3_policy.arn },
    { elasticache = module.pac_elasticache_redis.irsa_policy_arn }
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "combined_prepare_a_case_sqs" {
  statement {
    sid       = "prepareACaseSQSPolicy"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.crime-portal-gateway-queue.sqs_arn,
      module.crime-portal-gateway-dead-letter-queue.sqs_arn,
      module.court-cases-queue.sqs_arn,
      module.court-cases-dlq.sqs_arn,
      module.pic_new_offender_events_queue.sqs_arn,
      module.pic_new_offender_events_dead_letter_queue.sqs_arn,
      module.cpr-court-cases-queue.sqs_arn,
      module.cpr-court-cases-dlq.sqs_arn
    ]
  }
}

resource "aws_iam_policy" "combined_prepare_a_case_sqs" {
  policy = data.aws_iam_policy_document.combined_prepare_a_case_sqs.json
  tags   = local.default_tags
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

resource "aws_iam_policy" "read_only_s3_policy" {
  name   = "${var.namespace}-read-only-s3-policy"
  policy = data.aws_iam_policy_document.read_only_s3_access.json
}

data "aws_iam_policy_document" "read_only_s3_access" {
  statement {
    sid = "AllowReadAccessToS3Bucket"
    actions = [
      "s3:GetObject",
    ]
    resources = ["${module.large-court-cases-s3-bucket.bucket_arn}/*", ]
  }
}

resource "aws_iam_policy" "cross_namespace_s3_policy" {
  name   = "${var.namespace}-cross-namespace-s3-policy"
  policy = data.aws_iam_policy_document.cross_namespace_s3_access.json
}

data "aws_iam_policy_document" "cross_namespace_s3_access" {
  statement {
    sid = "AllowReadAccessToCrossNamespaceS3Bucket"
    actions = [
      "s3:GetObject",
    ]
    resources = ["${data.aws_ssm_parameter.cpr-large-court-cases-s3-bucket-arn.value}/*", ]
  }
}
