provider "pingdom" {
}

# Integration IDs
# 120233 = #probation-integration-notifications

resource "pingdom_check" "pi-production-check" {
  type                     = "http"
  name                     = "PI - ${var.application}"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain}"
  encryption               = true
  port                     = 443
  tags                     = "probation-integration,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [120233]
}

