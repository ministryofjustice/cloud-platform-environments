# For Cloud Platform deployed projects based on the hmpps-template-kotlin template:
# Make a copy of this file in your namespace, then modify according to the instructions here:
# https://tech-docs.hmpps.service.justice.gov.uk/creating-new-services/creating-resources-in-cloud-platform

module "hmpps_template_kotlin" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token            = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "hmpps-datahub-query-metrics"
  application                   = "hmpps-datahub-query-metrics"
  github_team                   = "hmpps-digital-prison-reporting"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  application_insights_instance = "prod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
