# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-prisoner-to-nomis-update"
  # we've almost hit the limit for policies here (limit is 15).  If wanting to add any more then switch to the
  # approach used in hmpps-prisoner-from-nomis-migration-prod/resources/irsa.tf instead.
  role_policy_arns = {
    hmpps_prisoner_to_nomis_adjudication_queue               = module.hmpps_prisoner_to_nomis_adjudication_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_adjudication_dead_letter_queue   = module.hmpps_prisoner_to_nomis_adjudication_dead_letter_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_nonassociation_queue             = module.hmpps_prisoner_to_nomis_nonassociation_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_nonassociation_dead_letter_queue = module.hmpps_prisoner_to_nomis_nonassociation_dead_letter_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_activity_queue                   = module.hmpps_prisoner_to_nomis_activity_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_activity_dead_letter_queue       = module.hmpps_prisoner_to_nomis_activity_dead_letter_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_appointment_queue                = module.hmpps_prisoner_to_nomis_appointment_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_appointment_dead_letter_queue    = module.hmpps_prisoner_to_nomis_appointment_dead_letter_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_incentive_queue                  = module.hmpps_prisoner_to_nomis_incentive_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_incentive_dead_letter_queue      = module.hmpps_prisoner_to_nomis_incentive_dead_letter_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_sentencing_queue                 = module.hmpps_prisoner_to_nomis_sentencing_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_sentencing_dead_letter_queue     = module.hmpps_prisoner_to_nomis_sentencing_dead_letter_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_visit_queue                      = module.hmpps_prisoner_to_nomis_visit_queue.irsa_policy_arn,
    hmpps_prisoner_to_nomis_visit_dead_letter_queue          = module.hmpps_prisoner_to_nomis_visit_dead_letter_queue.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
