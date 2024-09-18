provider "pingdom" {
}

resource "pingdom_check" "moj-frontend-production-pingdom" {
  type                     = "http"
  name                     = "MoJ design system guidance check"
  host                     = "design-patterns.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "business-unit_hq,application_moj-frontend,isproduction_true,environment-name_production,owner_mojds-maintainers:design-system@digital.justice.gov.uk"
  probefilters             = "region:EU"
  integrationids           = [139476]
}
