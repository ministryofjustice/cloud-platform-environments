provider "pingdom" {
}

resource "pingdom_check" "prepare-a-case-production-check" {
  type                     = "http"
  name                     = "${var.application}"
  host                     = "${var.prepare-case-domain}"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "hmpps, prepare-a-case, cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [110432]
}

