data "aws_iam_policy_document" "sqs_full_legacy" {
  version = "2012-10-17"
  statement {
    sid     = "hmppsManageIntelligenceLegacySqs"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.ims_extractor_queue.sqs_arn,
      module.ims_extractor_dead_letter_queue.sqs_arn,
      module.ims_transformer_queue.sqs_arn,
      module.ims_transformer_dead_letter_queue.sqs_arn,
      module.ims_test_generator_queue.sqs_arn,
      module.ims_generator_dead_letter_queue.sqs_arn,
      module.ims_test_generator_suite_queue.sqs_arn,
      module.ims_generator_suite_dead_letter_queue.sqs_arn,
      module.attachment_metadata_extractor_queue.sqs_arn,
      module.attachment_metadata_extractor_dead_letter_queue.sqs_arn,
      module.attachment_metadata_transformer_queue.sqs_arn,
      module.attachment_metadata_transformer_dead_letter_queue.sqs_arn,
      module.metadata_status_queue.sqs_arn,
      module.metadata_status_dead_letter_queue.sqs_arn
    ]
  }
}

resource "aws_iam_policy" "combined_sqs_legacy" {
  policy = data.aws_iam_policy_document.sqs_full_legacy.json
  # Tags
  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

module "irsa-legacy" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.application}-legacy-${var.environment}"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    policy         = aws_iam_policy.combined_sqs_legacy.arn
    s3_extractor   = module.manage_intelligence_extractor_bucket.irsa_policy_arn
    s3_transformer = module.manage_intelligence_transformer_bucket.irsa_policy_arn
    rds            = module.rds_aurora_legacy.irsa_policy_arn
    rds_test_gen   = module.rds_aurora_legacy_test_gen.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa-legacy" {
  metadata {
    name      = "irsa-legacy-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa-legacy.role_name
    serviceaccount = module.irsa-legacy.service_account.name
    rolearn        = module.irsa-legacy.role_arn
  }
}