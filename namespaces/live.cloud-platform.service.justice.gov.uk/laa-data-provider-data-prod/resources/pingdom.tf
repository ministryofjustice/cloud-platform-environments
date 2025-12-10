provider "pingdom" {
  api_key = var.pingdom_api_key
}

resource "pingdom_check" "laa_data_provider_data_prod" {
  name                     = "LAA Provider Details API PROD Healthcheck"
  host                     = "laa-provider-details-api-prod.apps.live.cloud-platform.service.justice.gov.uk"
  type                     = "http"
  url                      = "/actuator/health"
  encryption               = true
  resolution               = 1                # Check every minute
  notifywhenbackup         = true
  sendnotificationwhendown = 2                # Notify after 2 consecutive failures
  tags                     = "laa,prod,api,healthcheck"
  integrationids           = [145685]

  # Optional: expected HTTP status code
  # This ensures Pingdom marks the check as "up" only when it gets a 200 response
  requestheaders = {
    "Accept" = "application/json"
  }

  # You can optionally restrict to specific Pingdom regions:
  # probe_filters = "region:EU"
  # --- Operational Hours: 07:00–21:30 daily ---
  hoursofoperation {
    days_of_week = [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday"
    ]
    from = "07:00"
    to   = "21:30"
  }
}
