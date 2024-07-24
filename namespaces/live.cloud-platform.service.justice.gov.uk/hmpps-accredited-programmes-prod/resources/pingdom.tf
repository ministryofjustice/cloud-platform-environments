provider "pingdom" {}
resource "pingdom_check" "pingdom" {
  for_each = toset([
    "accredited-programmes-api.hmpps",
    "accredited-programmes.hmpps",
  ])
  type                     = "http"
  name                     = "ACP dependent service-  ${each.value}"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/${each.value}.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "accredited-programmes,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [135046]
}
