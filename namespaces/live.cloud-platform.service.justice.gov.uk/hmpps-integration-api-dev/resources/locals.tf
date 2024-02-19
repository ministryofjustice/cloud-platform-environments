locals {
  default_tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
    GithubTeam             = var.team_name
  }

  clients = ["emile", "chiara", "mapps", "heartbeat", "ctrlo", "cymulatetest"]
}
