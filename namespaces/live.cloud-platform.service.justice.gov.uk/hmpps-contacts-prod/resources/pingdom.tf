# Integration IDs
# 96624 = #dps_alerts

resource "pingdom_check" "hmpps-contacts-ui-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Contacts UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/contacts.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624]
}
