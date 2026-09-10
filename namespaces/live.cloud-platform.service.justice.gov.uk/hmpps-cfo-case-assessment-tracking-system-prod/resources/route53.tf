resource "aws_route53_zone" "cats_prod" {
  name = "manage-external-funded-offender-provision.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "cats_prod_route53_zone" {
  metadata {
    name      = "cats-prod-route53-zone-output"
    namespace = var.namespace
  }

  # Step 2. Domains team
  # When you're happy that all the records below are identical to what's live in the legacy
  # AWS account, extract this secret with kubectl and share the nameservers with domains-gg
  # to delegate the whole apex zone to us.
  #   kubectl -n hmpps-cfo-case-assessment-tracking-system-prod get secret \
  #     cats-prod-route53-zone-output -o jsonpath='{.data.nameservers}' | base64 -d
  #
  # Step 3. Traffic will still be served from the legacy AWS account (records below are
  # identical copies of what's already live) - delegation alone changes nothing functionally.
  #
  # Step 4. Create certificates (e.g. 05-certificate.yaml) ahead of time once CP manages the
  # DNS. TLS secrets can only be issued once CP is authoritative for the zone.
  # Useful commands: kubectl get certificates / kubectl get certificaterequests
  #
  # Step 5. Cutover, done in two batches - non-prod (dev/training/preprod) together first,
  # then prod separately later. For each batch:
  #   5.1 delete the relevant host record(s) below (dev/training/preprod records for batch 1,
  #       apex record for batch 2) - NOT the *_acm_validation records, those stay for now
  #   5.2 immediately merge/deploy the matching CATS ingress PR - external-dns will then create
  #       the replacement weighted record(s). The old simple-routing record must be gone first,
  #       since Route53 won't allow it alongside external-dns's weighted record for the same host
  #   5.3 verify each hostname resolves to CP and serves correctly
  #   5.4 decommission the legacy CloudFront distribution(s) for that batch's hosts
  #   5.5 once decommissioned, remove that batch's *_acm_validation record(s) below too (they
  #       only validate the legacy ACM cert, unrelated to our cert-manager cert - see note
  #       above on why this isn't forced/immediate)
  data = {
    zone_id     = aws_route53_zone.cats_prod.zone_id
    nameservers = join("\n", aws_route53_zone.cats_prod.name_servers)
  }
}

# ---------------------------------------------------------------------------
# Step 1. Replicated records - exact copies of what's currently live in the legacy AWS account
# ---------------------------------------------------------------------------

# --- apex/production start ---
# NOTE: the domains team suggested converting our ALIAS records to CNAME for consistency
# (applied to "dev" below). This one is kept as an ALIAS instead, since a CNAME record is
# not permitted at a zone apex/root (RFC 1034), and this name is the apex of the cats_prod
# hosted zone above - ALIAS is the only valid way to point it at CloudFront.
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "A"
  alias {
    name                   = "d3tubljexqypxg.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront's fixed hosted zone ID
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "apex_acm_validation" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "_e423c56d23dc0dce73d7af3276cfd0e6.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["_e74deb9ca8229527592f88459265f1ef.kirrbxfjtw.acm-validations.aws."]
}
# --- apex/production end ---


# --- dev start ---
resource "aws_route53_record" "dev" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "dev.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["d3gjnixuqv4h4f.cloudfront.net"]
}

resource "aws_route53_record" "dev_acm_validation" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "_d8e015eb77621a22d1bb4fe339ec1ebd.dev.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["_f45d3bd1f2f3aa9f672facf92f66d56a.sdgjtdhdhz.acm-validations.aws."]
}
# --- dev end ---

# --- training start ---
resource "aws_route53_record" "training" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "training.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["d2xa34imt80u6b.cloudfront.net"]
}

resource "aws_route53_record" "training_acm_validation" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "_82cde6f94d128501499619acb1b642f4.training.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["_556342720a60ba23735a0b41ba123f7b.djqtsrsxkq.acm-validations.aws."]
}
# --- training end ---

# --- preprod start ---
resource "aws_route53_record" "preprod" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "preprod.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["dnsmo1f6n0f63.cloudfront.net"]
}

resource "aws_route53_record" "preprod_acm_validation" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "_8f2a1999a9e110af3685208ee3875799.preprod.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["_319d4c72bdfe59b5b6d40f8409b78e65.sdgjtdhdhz.acm-validations.aws."]
}
# --- preprod end ---

# --- legacy CFO3/CATS start ---
resource "aws_route53_record" "legacy" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "legacy.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["d2p66dhqonjkjj.cloudfront.net"]
}

resource "aws_route53_record" "legacy_acm_validation" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "_d77aef5e838aac4d3d7761ad92401c78.legacy.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["_414290eebad8535f016569d8e6055684.sdgjtdhdhz.acm-validations.aws."]
}
# --- legacy CFO3/CATS end ---

# --- uat start (todo: remove as unused) ---
resource "aws_route53_record" "uat" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "uat.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["d35an6ch35u5jb.cloudfront.net"]
}

resource "aws_route53_record" "uat_acm_validation" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "_5bbd77a4d881573bfe10b4fcca0d4579.uat.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["_7ea920d16b055881c2a4dae81f31ca6c.xlfgrmvvlj.acm-validations.aws."]
}
# --- uat end ---

# --- accessibility start (todo: remove as unused) ---
resource "aws_route53_record" "accessibility" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "accessibility.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["d1odphpda4fk81.cloudfront.net"]
}

resource "aws_route53_record" "accessibility_acm_validation" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "_2cf3aee75260c043ab7bf7625aa4b527.accessibility.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["_a7dcc4b9fda9896900ae733516c6193d.xlfgrmvvlj.acm-validations.aws."]
}
# --- accessibility end ---

# --- preprod.visualiser start (todo: remove as unused) ---
resource "aws_route53_record" "preprod_visualiser" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "preprod.visualiser.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["d3jlsovjv477z1.cloudfront.net"]
}

# NOTE: source spreadsheet truncated this name to "...manage-external-funded-offender-provision"
# with no ".service.justice.gov.uk" suffix - verify the exact FQDN against the legacy zone
# before applying, otherwise ACM validation for preprod.visualiser will fail.
resource "aws_route53_record" "preprod_visualiser_acm_validation" {
  zone_id = aws_route53_zone.cats_prod.zone_id
  name    = "_bdcfe721a7cbf0bcfed8b2dc6a8a6512.preprod.visualiser.manage-external-funded-offender-provision.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = ["_4a0d681394880a4236091bb3f5030875.jkddzztszm.acm-validations.aws."]
}
# --- preprod.visualiser end ---