data "aws_ssm_parameter" "hmpps-appinsights-t3-arn" {
  name = "/hmpps-portfolio-management-dev/appinsights_t3-arn"
}

resource "kubernetes_secret" "appinsights-t3" {
  metadata {
    name      = "appinsights-t3"
    namespace = var.namespace
  }
  data = {
    APPINSIGHTS_INSTRUMENTATIONKEY = base64encode(data.aws_ssm_parameter.hmpps-appinsights-t3-arn.value)
    APPLICATIONINSIGHTS_CONNECTION_STRING = base64encode(format("%s/%s","InstrumentationKey=",data.aws_ssm_parameter.hmpps-appinsights-t3-arn.value))
  }
}