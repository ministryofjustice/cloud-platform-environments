locals {
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
  dns_endpoint_rules = {
    "TCP_53" : {
      "from_port" : 53,
      "to_port" : 53,
      "protocol" : "TCP"
    },
    "UDP_53" : {
      "from_port" : 53,
      "to_port" : 53,
      "protocol" : "UDP"
    }
  }
  ips = ["ip1", "ip2", "ip3"]
}
