provider "pingdom" {
}

resource "pingdom_check" "hale-dev-example" {
    type                     = "http"
    name                     = "Website-Builder-Dev-Platform-Page"
    host                     = "hale-platform-dev.apps.live.cloud-platform.service.justice.gov.uk"
    resolution               = 1
    notifywhenbackup         = true
    sendnotificationwhendown = 6
    notifyagainevery         = 0
    url                      = "/"
    encryption               = true
    port                     = 443
    tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},infrastructuresupport_${var.application}"
    probefilters             = "region:EU"
    integrationids           = [133317]
}


resource "pingdom_maintenance" "hale-test" {
  description    = "hale-test-maintenance"
  from           = 1713996000
  to             = 1714024800
  effectiveto    = 1714341600
  recurrencetype = "day"
  uptimeids      = [pingdom_check.hale-dev-example.id]
}

resource "pingdom_occurrence" "test" {
  maintenance_id = pingdom_maintenance.hale-test.id
  effective_from = pingdom_maintenance.hale-test.from
  effective_to   = pingdom_maintenance.hale-test.effectiveto
  from           = pingdom_maintenance.hale-test.from
  to             = "2024-04-28T22:00:00+08:00"
}