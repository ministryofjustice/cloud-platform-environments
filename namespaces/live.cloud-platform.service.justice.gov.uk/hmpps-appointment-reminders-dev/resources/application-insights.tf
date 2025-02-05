data "aws_ssm_parameter" "application_insights_key" {
  name = "/application_insights/key-${var.environment_name}"
}

resource "kubernetes_secret" "application-insights" {
  metadata {
    name      = "application-insights"
    namespace = var.namespace
  }
  data = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = "InstrumentationKey=${data.aws_ssm_parameter.application_insights_key.value}"
  }
}
