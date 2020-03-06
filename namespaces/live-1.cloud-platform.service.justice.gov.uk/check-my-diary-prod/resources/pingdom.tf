provider "pingdom" {
}

# Integration IDs
# 100724 =  #check-my-diary-alerts

resource "pingdom_check" "dps-production-check-check-my-diary" {
  type                     = "http"
  name                     = "DPS - checkmydiary.service.justice.gov.uk"
  host                     = "checkmydiary.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [100724]
}

