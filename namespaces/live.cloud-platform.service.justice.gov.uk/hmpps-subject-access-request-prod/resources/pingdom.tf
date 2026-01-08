provider "pingdom" {
}

resource "pingdom_check" "subject-access-request-ui-prod-check" {
  type                     = "http"
  name                     = "HMPPS - hmpps-subject-access-request-ui - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/subject-access-request.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-subject-access-request,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [146296] #subject-access-request-alerts-prod
}

resource "pingdom_check" "subject-access-request-api-prod-check" {
  type                     = "http"
  name                     = "HMPPS - hmpps-subject-access-request-api - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/subject-access-request-api.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-subject-access-request,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [146296] #subject-access-request-alerts-prod
}

resource "pingdom_check" "subject-access-request-worker-prod-check" {
  type                     = "http"
  name                     = "HMPPS - hmpps-subject-access-request-worker - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/subject-access-request-worker.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-subject-access-request,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [146296] #subject-access-request-alerts-prod
}

resource "pingdom_check" "subject-access-request-html-renderer-prod-check" {
  type                     = "http"
  name                     = "HMPPS - hmpps-subject-access-request-html-renderer - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/subject-access-request-html-renderer.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-subject-access-request,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [146296] #subject-access-request-alerts-prod
}
