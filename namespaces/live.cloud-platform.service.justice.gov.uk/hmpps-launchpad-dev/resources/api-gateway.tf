module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "dev-http"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  domain_name = "terraform-aws-modules.modules.tf"

  # Access logs
  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = 7
    format = jsonencode({
      context = {
        domainName              = "$context.domainName"
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }

  # Authorizer(s)
  authorizers = {
    "azure" = {
      authorizer_type  = "JWT"
      identity_sources = ["$request.header.Authorization"]
      name             = "azure-auth"
      jwt_configuration = {
        audience         = ["d6a38afd-45d6-4874-d1aa-3c5c558aqcc2"]
        issuer           = "https://sts.windows.net/aaee026e-8f37-410e-8869-72d9154873e4/"
      }
    }
  }

  # Routes & Integration(s)
  routes = {
    "POST /" = {
      integration = {
        uri                    = "arn:aws:lambda:eu-west-1:052235179155:function:my-function"
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    }

    "GET /some-route-with-authorizer" = {
      authorizer_key = "azure"

      integration = {
        type = "HTTP_PROXY"
        uri  = "some url"
      }
    }

    "$default" = {
      integration = {
        uri = "arn:aws:lambda:eu-west-1:052235179155:function:my-default-function"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}