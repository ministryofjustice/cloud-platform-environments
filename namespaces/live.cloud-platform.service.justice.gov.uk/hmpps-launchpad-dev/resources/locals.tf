locals {
  default_tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }

  ingress_ips = toset(flatten([
    for lb in try(data.kubernetes_service.ingress_controller.status[0].load_balancer[*].ingress, []) : [
      for ing in lb : ing.ip if try(ing.ip, null) != null && ing.ip != ""
    ]
  ]))



  # API Gateway clients
  api_clients = [
    "nutrition-app-dev",
    "app-2-dev",
    "app-3-dev",]
}