provider "pingdom" {
}

# Integration IDs
# 100724 =  #check-my-diary-alerts
# 107200 =  check my diary - pagerduty
# 126478 = #syscon-alerts

resource "pingdom_check" "dps-production-check-check-my-diary" {
  type                     = "http"
  name                     = "CMD - checkmydiary.service.justice.gov.uk"
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
  integrationids           = [126478]
}

resource "pingdom_check" "dps-production-check-cmd-api" {
  type                     = "http"
  name                     = "CMD - cmd-api.service.justice.gov.uk"
  host                     = "cmd-api.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [126478]
}

resource "pingdom_check" "dps-production-check-csr-api" {
  type                     = "http"
  name                     = "CMD - csr-api.service.justice.gov.uk"
  host                     = "csr-api.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [126478]
}
