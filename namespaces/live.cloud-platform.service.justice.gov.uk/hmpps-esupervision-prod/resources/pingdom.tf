provider "pingdom" {
}

resource "pingdom_check" "probation-check-in-prod" {
  type                     = "http"
  name                     = "Check in with your probation officer"
  host                     = "probation-check-in.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${lower(var.business_unit)},application_${var.application},isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
}