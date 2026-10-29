module "hmpps-pin-phone-api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo = "hmpps-pin-phone-api"
  application = "hmpps-pin-phone-api"
  github_team = "hmpps-digital-canteen-devs"
  environment = var.environment
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "hmpps-pin-phone-medusa-service" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo = "hmpps-pin-phone-medusa-service-api"
  application = "hmpps-pin-phone-medusa-service"
  github_team = "hmpps-digital-canteen-devs"
  environment = var.environment
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "hmpps-pin-phone-ui" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo = "hmpps-pin-phone-ui"
  application = "hmpps-pin-phone-ui"
  github_team = "hmpps-digital-canteen-devs"
  environment = var.environment
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
