provider "pingdom" {
}

resource "pingdom_check" "laa-crown-court-litigator-fees-staging" {
  type                     = "http"
  name                     = "Crown Court Litigator Fees Staging"
  host                     = "cclf-staging.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/cclf/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  integrationids           = [139834]
}