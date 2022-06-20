provider "pingdom" {
}

# Integration IDs
# 96624 = #dps_alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "send-legal-mail-to-prisons-production-check" {
  type                     = "http"
  name                     = "${var.application} - Legal Sender application"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.send_legal_mail_to_prisons_domain}"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [122536]
}

resource "pingdom_check" "check-rule39-mail-production-check" {
  type                     = "http"
  name                     = "${var.application} - Mail Room Staff application"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.check_rule39_mail_domain}"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [122536]
}
