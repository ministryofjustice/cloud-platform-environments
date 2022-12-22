provider "pingdom" {}

resource "pingdom_check" "search-api-check" {
  type                     = "http"
  name                     = "${var.application} API"
  host                     = "probation-offender-search.hmpps.service.justice.gov.uk"
  port                     = 443
  url                      = "/health"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "probation-integration,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [120233] # probation-integration-notifications
}

resource "pingdom_check" "indexer-ingress-check" {
  type                     = "http"
  name                     = "${var.application} Elasticsearch Ingress"
  host                     = "probation-search-prod.hmpps.service.justice.gov.uk"
  port                     = 443
  url                      = "/health"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "probation-integration,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [120233] # probation-integration-notifications
}

