resource "aws_route53_zone" "main" {
  name = "form.service.justice.gov.uk"

  tags {
    business-unit          = "transformed-department"
    application            = "formbuilder"
    is-production          = "${var.is-production}"
    environment-name       = "${var.environment-name}"
    owner                  = "${var.team_name}"
    infrastructure-support = "${var.infrastructure-support}"
  }
}
