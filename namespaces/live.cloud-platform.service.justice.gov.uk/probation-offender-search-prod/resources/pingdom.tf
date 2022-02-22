provider "pingdom" {
}

# Integration IDs
# 120233 = #probation-integration-notifications

resource "pingdom_check" "psi-production-check" {
  type                     = "http"
  name                     = "PI - probation-offender-search-indexer"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain_psi}"
  encryption               = true
  port                     = 443
  tags                     = "probation-integration,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [120233]
}

resource "pingdom_check" "pos-production-check" {
  type                     = "http"
  name                     = "PI - probation-offender-search"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain_pos}"
  encryption               = true
  port                     = 443
  tags                     = "probation-integration,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [120233]
}

