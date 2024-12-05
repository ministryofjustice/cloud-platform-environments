provider "pingdom" {
}

resource "pingdom_check" "laa-assess-crime-forms-prod" {
  type             = "http"
  name             = "${var.application} ${var.environment} - ping"
  host             = "assess-crime-forms.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  sendnotificationwhendown = 6
  notifyagainevery = 0
  url              = "/ping"
  encryption       = true
  port             = 443
  tags             = "businessunit_${var.business_unit},application_${var.namespace},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name}"
  probefilters     = "region:EU"
  integrationids   = [135343]
}
