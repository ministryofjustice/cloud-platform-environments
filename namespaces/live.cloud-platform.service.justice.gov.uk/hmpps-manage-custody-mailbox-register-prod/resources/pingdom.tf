provider "pingdom" {
}

# Integration IDs
# 141423 = #mpc_alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "hmpps-mailbox-register-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Manage Custody Mailbox Register"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/manage-custody-mailbox-register.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141423, 96628]
}
