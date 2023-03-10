module "hmpps-domain-events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.7.0"

  topic_display_name = "hmpps-domain-events"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure-support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_iam_access_key" "key_2023" {
  user = module.hmpps-domain-events.user_name
}

resource "kubernetes_secret" "hmpps-domain-events-new-key" {
  metadata {
    name      = "hmpps-domain-events-new-key"
    namespace = "hmpps-domain-events-prod"
  }

  data = {
    access_key_id     = aws_iam_access_key.key_2023.id
    secret_access_key = aws_iam_access_key.key_2023.secret
  }
}
