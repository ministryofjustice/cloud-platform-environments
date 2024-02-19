module "irsa-legacy" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.application}-legacy-${var.environment-name}"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    sqs_extractor           = module.ims_extractor_queue.irsa_policy_arn
    sqs_extractor_dlq       = module.ims_extractor_dead_letter_queue.irsa_policy_arn
    sqs_transformer         = module.ims_transformer_queue.irsa_policy_arn
    sqs_transformer_dlq     = module.ims_transformer_dead_letter_queue.irsa_policy_arn
    sqs_lastupdate          = module.ims_lastupdate_queue.irsa_policy_arn
    sqs_lastupdate_dlq      = module.ims_lastupdate_dead_letter_queue.irsa_policy_arn
    sqs_generator           = module.ims_test_generator_queue.irsa_policy_arn
    sqs_generator_dlg       = module.ims_generator_dead_letter_queue.irsa_policy_arn
    sqs_generator_suite     = module.ims_test_generator_suite_queue.irsa_policy_arn
    sqs_generator_suite_dlg = module.ims_generator_suite_dead_letter_queue.irsa_policy_arn
    s3_extractor            = module.manage_intelligence_extractor_bucket.irsa_policy_arn
    s3_transformer          = module.manage_intelligence_transformer_bucket.irsa_policy_arn
    rds                     = module.rds_aurora_legacy.irsa_policy_arn
    rds_test_gen            = module.rds_aurora_legacy_test_gen.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
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