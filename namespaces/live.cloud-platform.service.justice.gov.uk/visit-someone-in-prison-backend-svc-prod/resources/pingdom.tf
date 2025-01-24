provider "pingdom" {
}

# Integration IDs
# 141228 = #visits-alerts

resource "pingdom_check" "visit-scheduler-production-check" {
  type                     = "http"
  name                     = "Visit Scheduler"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/visit-scheduler.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141228]
}

resource "pingdom_check" "prisoner-contact-registry-production-check" {
  type                     = "http"
  name                     = "Prisoner Contact Registry"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/prisoner-contact-registry.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141228]
}

resource "pingdom_check" "prison-visits-orchestration-service-production-check" {
  type                     = "http"
  name                     = "Manage Prison Visits Orchestration Service"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/hmpps-manage-prison-visits-orchestration.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141228]
}

# TODO: Commented out as not in production yet
# resource "pingdom_check" "vsip-alerts-notifications-service-production-check" {
#   type                     = "http"
#   name                     = "VSiP Alerts Notifications"
#   host                     = "health-kick.prison.service.justice.gov.uk"
#   resolution               = 1
#   notifywhenbackup         = true
#   sendnotificationwhendown = 6
#   notifyagainevery         = 0
#   url                      = "/https/hmpps-notifications-alerts-vsip.prison.service.justice.gov.uk"
#   encryption               = true
#   port                     = 443
#   tags                     = "dps,hmpps,cloudplatform-managed"
#   probefilters             = "region:EU"
#   integrationids           = [141228]
# }
