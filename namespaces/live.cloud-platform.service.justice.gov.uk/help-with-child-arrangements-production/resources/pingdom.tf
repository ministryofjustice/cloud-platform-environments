provider "pingdom" {}

resource "pingdom_check" "help-with-child-arrangements-production-cloud-platform-healthcheck" {
  type                     = "http"
  name                     = "CAIT Child Arrangements Info Tool - Production - Healthcheck"
  host                     = "helpwithchildarrangements.service.justice.gov.uk "
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_central_digital,application_help_with_child_arrangements,component_healthcheck,isproduction_true,environment_production"
  probefilters             = "region:EU"
  integrationids           = [139835]
}
