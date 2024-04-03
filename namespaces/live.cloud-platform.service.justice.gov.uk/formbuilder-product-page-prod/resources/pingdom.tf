provider "pingdom" {}

resource "pingdom_check" "fb_services_pingdom" {
  type                     = "http"
  name                     = "Form Builder - Product Page"
  host                     = "moj-forms.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping.json"
  encryption               = true
  port                     = 443
  tags                     = "moj-forms"
  probefilters             = "region:EU"
  integrationids           = [100321]
}
