provider "pingdom" {}

locals {
  forms = {
    apply-financial-deputy         = "apply-financial-deputy.form.service.justice.gov.uk",
    apply-financial-deputy-upfront = "apply-financial-deputy-upfront.form.service.justice.gov.uk",
    ccrc                           = "ccrc.form.service.justice.gov.uk",
    childrens-funeral-fund         = "claim-for-costs-of-a-childs-funeral.form.service.justice.gov.uk",
    cica                           = "same-roof-rule.form.service.justice.gov.uk",
    complain-about-a-court         = "complain-about-a-court-or-tribunal.form.service.justice.gov.uk",
    complain-to-the-cica           = "complain-to-the-cica.form.service.justice.gov.uk",
    contact-the-cica               = "contact-the-cica.form.service.justice.gov.uk",
    give-feedback                  = "comments-form.form.service.justice.gov.uk",
    house-disrepair                = "check-how-to-get-repairs-done-in-your-rented-home.form.service.justice.gov.uk",
    leavers-form                   = "leavers.form.service.justice.gov.uk",
    miscarriages-of-justice        = "miscarriages-of-justice.form.service.justice.gov.uk",
    moj-forms                      = "moj-forms.service.justice.gov.uk",
    money-claim-queries            = "money-claim-queries.form.service.justice.gov.uk",
    publisher                      = "fb-publisher-live.apps.live.cloud-platform.service.justice.gov.uk",
    report-security-incident       = "report-security-incident.form.service.justice.gov.uk",
    request-personal-info          = "request-personal-info.form.service.justice.gov.uk",
    say-thank-you                  = "user-feedback.form.service.justice.gov.uk"
  }
  names = keys(local.forms)
  hosts = values(local.forms)
}

resource "pingdom_check" "fb_services_pingdom" {
  count                    = length(local.forms)
  type                     = "http"
  name                     = "Form Builder - ${local.names[count.index]}"
  host                     = local.hosts[count.index]
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping.json"
  encryption               = true
  port                     = 443
  tags                     = local.names[count.index]
  probefilters             = "region:EU"
  integrationids           = [100321]
}
