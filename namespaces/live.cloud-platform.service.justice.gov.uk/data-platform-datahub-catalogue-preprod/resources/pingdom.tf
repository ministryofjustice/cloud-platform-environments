provider "pingdom" {
}

locals {
  urls = {
    "frontend-healthcheck" = { url = "/admin" }
    "gms-mainpage"         = { url = "/" }
    "gms-domains"          = { url = "/domain" }
    "gms-search"           = { url = "/search" }
  }
}

resource "pingdom_check" "datahub-catalogue-preprod" {
  for_each                 = local.urls
  type                     = "http"
  name                     = "datahub-catalogue - preprod - ${each.key} - cloud-platform"
  host                     = "datahub-catalogue-preprod.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = each.value.url
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_datahub_catalogue,component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.business_unit}"
  probefilters             = "region:EU"
  integrationids           = [135556]
}
