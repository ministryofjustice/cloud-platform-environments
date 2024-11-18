########################### IMPORTANT ##################################
## This parameter determines which application insights account is used
## so you will need to change depending on environment

data "aws_ssm_parameter" "application_insights_key" {

## dev (t3) = /application_insights/key-dev
## preprod  = /application_insights/key-preprod
## prod     = /application_insights/key-prod

  name = "/application_insights/key-dev"
}

########################################################################

resource "kubernetes_secret" "application-insights" {
  metadata {
    name      = "application-insights"
    namespace = var.namespace
  }
  data = {
    APPINSIGHTS_INSTRUMENTATIONKEY = data.aws_ssm_parameter.application_insights_key.value
    APPLICATIONINSIGHTS_CONNECTION_STRING = format("%s%s","InstrumentationKey=",data.aws_ssm_parameter.application_insights_key.value)
  }
}