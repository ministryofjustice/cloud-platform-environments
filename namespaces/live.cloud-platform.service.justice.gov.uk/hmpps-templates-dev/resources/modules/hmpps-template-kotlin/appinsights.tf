data "aws_ssm_parameter" "application_insights_key" {
  name = "/application_insights/key-${var.application_insights_instance}"
}

resource "kubernetes_secret" "application-insights" {
  metadata {
    name      = "${var.application}-application-insights"
    namespace = var.namespace
  }
  data = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = data.aws_ssm_parameter.application_insights_key.value
    APPLICATIONINSIGHTS_CONNECTION_STRING = "InstrumentationKey=${data.aws_ssm_parameter.application_insights_key.value}"
  }
}
