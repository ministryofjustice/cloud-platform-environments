provider "pingdom" {
}

# Integration IDs
# 94314 = #pecs-alerts
# 108715 = PECS Pager Duty

resource "pingdom_check" "book-secure-move-frontend-check" {
  type                     = "http"
  name                     = "Book Secure Move Frontend - bookasecuremove.service.justice.gov.uk"
  host                     = "bookasecuremove.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/healthcheck"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [94314, 108715]
}
