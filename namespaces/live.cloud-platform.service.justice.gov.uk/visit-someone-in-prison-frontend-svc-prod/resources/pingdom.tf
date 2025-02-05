provider "pingdom" {
}

# Integration IDs
# 141228 = #visits-alerts

resource "pingdom_check" "visit-someone-in-prison-staff-ui-production-check" {
  type                     = "http"
  name                     = "Visit Someone in Prison Staff UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/manage-prison-visits.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141228]
}

resource "pingdom_check" "visit-someone-in-prison-internal-ui-production-check" {
  type                     = "http"
  name                     = "Visit Someone in Prison Internal UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/visits-internal-admin.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141228]
}

# Todo: Commented out as site not in production yet
# resource "pingdom_check" "visit-someone-in-prison-public-ui-production-check" {
#   type                     = "http"
#   name                     = "Visit Someone in Prison Public UI"
#   host                     = "visit.prison.service.justice.gov.uk"
#   resolution               = 1
#   notifywhenbackup         = true
#   sendnotificationwhendown = 6
#   notifyagainevery         = 0
#   url                      = "/ping"
#   encryption               = true
#   port                     = 443
#   tags                     = "dps,hmpps,cloudplatform-managed"
#   probefilters             = "region:EU"
#   integrationids           = [141228]
# }
