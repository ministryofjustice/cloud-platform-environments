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
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${each.value}"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_prisoner_content_hub,component_healthcheck,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_platforms"
  probefilters             = "region:EU"
  publicreport             = "true"

  integrationids = [
    106307 # #pfs_dev channel
    # 106310, # #pfs_alerts channel
  ]
}
