# For Cloud Platform deployed projects based on the hmpps-template-kotlin template:

module "hmpps_ref_data_kotlin" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"  
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo = "hmpps-reference-data-api"  
  application = "hmpps-reference-data"
  github_team = "hmpps-pds-platform-devs"
  environment = var.environment 

  
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster

}