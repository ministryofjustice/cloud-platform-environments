resource "pingdom_check" "hmpps-rl-dps-microsvc-dev" {
  type                     = "http"
  name                     = "hmpps-rl-dps-microsvc-dev - DEV"
  host                     = "hmpps-rl-dps-microsvc-dev.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,make-recall-decision,dev,isproduction_false,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [121586]
}

