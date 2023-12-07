data "aws_iam_policy_document" "sqs_full" {
  version = "2012-10-17"
  statement {
    sid     = "hmppsManageIntelligenceSqs"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.ims_index_batch_queue.sqs_arn,
      module.ims_index_batch_dead_letter_queue.sqs_arn,
      module.ims_index_update_queue.sqs_arn,
      module.ims_index_update_dead_letter_queue.sqs_arn,
      module.ims_transformer_queue.sqs_arn,
      module.ims_transformer_dead_letter_queue.sqs_arn,
      module.ims_lastupdate_queue.sqs_arn,
      module.ims_lastupdate_dead_letter_queue.sqs_arn,
      module.ims_reprocess_queue.sqs_arn,
      module.ims_reprocess_dead_letter_queue.sqs_arn,
      module.ims_csv_queue.sqs_arn,
      module.ims_csv_dead_letter_queue.sqs_arn
    ]
  }
}

resource "aws_iam_policy" "combined_sqs" {
  policy = data.aws_iam_policy_document.sqs_full.json
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

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.application}-${var.environment}"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    policy              = aws_iam_policy.combined_sqs.arn
    s3_ims              = module.manage_intelligence_storage_bucket.irsa_policy_arn
    s3_rds              = module.manage_intelligence_rds_to_s3_bucket.irsa_policy_arn
    s3_transformer      = module.manage_intelligence_transformer_bucket.irsa_policy_arn
    s3_csv              = module.manage_intelligence_csv_bucket.irsa_policy_arn
    rds                 = module.rds_aurora.irsa_policy_arn
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
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}