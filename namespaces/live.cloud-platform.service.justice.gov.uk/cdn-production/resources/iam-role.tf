module "s3_access_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "5.55.0"

  name_prefix = "${var.namespace}-s3-access"
  path        = "/cloud-platform/"

  subjects = ["ministryofjustice/cdn:*"]

  policies = {
    s3_access = module.s3_access_iam_policy.arn
  }

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "s3_access_iam_role" {
  metadata {
    name      = "s3-access-iam-role"
    namespace = var.namespace
  }

  data = {
    role_arn = module.s3_access_iam_role.arn
  }
}
