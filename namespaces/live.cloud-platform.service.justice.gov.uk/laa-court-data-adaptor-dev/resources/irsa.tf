module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "laa-court-data-adaptor-irsa"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    cp_test_queue = module.cp_test_queue.irsa_policy_arn
    create_link_queue_m = module.create_link_queue_m.irsa_policy_arn
    create_link_queue_m_dead_letter_queue = module.create_link_queue_m_dead_letter_queue.irsa_policy_arn
    unlink_queue_m = module.unlink_queue_m.irsa_policy_arn
    unlink_queue_m_dead_letter_queue = module.unlink_queue_m_dead_letter_queue.irsa_policy_arn
    hearing_resulted_queue = module.hearing_resulted_queue.irsa_policy_arn
    hearing_resulted_dead_letter_queue = module.hearing_resulted_dead_letter_queue.irsa_policy_arn
    prosecution_concluded_queue = module.prosecution_concluded_queue.irsa_policy_arn
    prosecution_concluded_dl_queue = module.prosecution_concluded_dl_queue.irsa_policy_arn
    court_data_adaptor_rds=module.court_data_adaptor_rds.irsa_policy_arn
    crime_apps_ec_cluster=module.crime_apps_ec_cluster.irsa_policy_arn
}

# Tags
business_unit          = var.business_unit
application            = var.application
is_production          = var.is_production
team_name              = var.team_name
environment_name       = var.environment_name
infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}
