data "aws_ssm_parameter" "application_insights_key_t3" {
  name = "/application_insights/key_t3"
}

resource "kubernetes_secret" "application-insights" {
  metadata {
    name      = "application-insights"
    namespace = var.namespace
  }
  data = {
    APPINSIGHTS_INSTRUMENTATIONKEY = base64encode(data.aws_ssm_parameter.application_insights_key_t3.value)
    APPLICATIONINSIGHTS_CONNECTION_STRING = base64encode(format("%s/%s","InstrumentationKey=",data.aws_ssm_parameter.application_insights_key_t3.value))
  }
}
