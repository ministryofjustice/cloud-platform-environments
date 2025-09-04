data "aws_ssm_parameter" "application_insights_key" {
  # var.environment should be set to one of dev, preprod or prod
  # otherwise the key has to be hard-coded e.g. key-preprod if environment set to 'pre-production'.
  name = "/application_insights/key-dev"
}

resource "kubernetes_secret" "application-insights" {
  metadata {
    name      = "application-insights"
    namespace = var.namespace
  }
  data = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = data.aws_ssm_parameter.application_insights_key.value
    APPLICATIONINSIGHTS_CONNECTION_STRING = "InstrumentationKey=${data.aws_ssm_parameter.application_insights_key.value};IngestionEndpoint=https://northeurope-0.in.applicationinsights.azure.com/;LiveEndpoint=https://northeurope.livediagnostics.monitor.azure.com/"
  }
}
