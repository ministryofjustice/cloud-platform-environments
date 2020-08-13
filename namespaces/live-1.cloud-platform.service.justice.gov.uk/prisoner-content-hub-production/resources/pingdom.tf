provider "pingdom" {
}

resource "pingdom_check" "prisoner-content-hub-production-checks" {
  for_each = {
    drupal-cms  = "manage.content-hub.prisoner.service.justice.gov.uk",
    berwyn      = "berwyn.content-hub.prisoner.service.justice.gov.uk",
    cookhamwood = "cookhamwood.content-hub.prisoner.service.justice.gov.uk",
    wayland     = "wayland.content-hub.prisoner.service.justice.gov.uk",
  }

  type                     = "http"
  name                     = "Prisoner Content Hub Production ${each.key}"
  host                     = each.value
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_${var.application},component_healthcheck,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_${var.infrastructure-support}"
  probefilters             = "region:EU"
  publicreport             = "true"

  integrationids = [
    106307, # #pfs_dev channel
    106310, # #pfs_alerts channel
  ]
}
