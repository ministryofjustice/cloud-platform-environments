provider "pingdom" {
}

resource "pingdom_check" "laa_data_provider_data_uat" {

  name                     = "LAA Provider Details API UAT Healthcheck"
  host                     = "laa-provider-details-api-uat.apps.live.cloud-platform.service.justice.gov.uk"
  type                     = "http"
  url                      = "/actuator/health"
  encryption               = true
  resolution               = 1                # Check every minute
  notifywhenbackup         = true
  sendnotificationwhendown = 2                # Notify after 2 consecutive failures
  tags                     = "laa,uat,api,healthcheck"
  integrationids           = [145876]

  # Optional: expected HTTP status code
  # This ensures Pingdom marks the check as "up" only when it gets a 200 response
  requestheaders = {
    "Accept" = "application/json"
  }
}
