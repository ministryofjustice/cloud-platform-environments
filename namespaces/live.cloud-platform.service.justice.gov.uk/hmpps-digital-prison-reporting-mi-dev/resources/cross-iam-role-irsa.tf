module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "dpr-reporting-mi-${var.environment}-cross-iam"
  namespace            = var.namespace
  role_policy_arns     = { 
    secrets = aws_iam_policy.cross_iam_policy_mp.arn 
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "cross_iam_policy_mp" {
  statement {
    actions = [
      "secretsmanager:Get*",
      "secretsmanager:List*",
    ]
    resources = [
      "arn:aws:secretsmanager:eu-west-2:771283872747:secret:dpr-redshift-secret-*-*",
      "arn:aws:secretsmanager:eu-west-2:972272129531:secret:dpr-redshift-secret-*-*",
      "arn:aws:secretsmanager:eu-west-2:004723187462:secret:dpr-redshift-secret-*-*",
      "arn:aws:secretsmanager:eu-west-2:203591025782:secret:dpr-redshift-secret-*-*",
    ]
  },
  {
    actions = [
      "kms:Describe*",
      "kms:Decrypt",
      "kms:Get*",
      "kms:List*",
    ]
    resources = [
      "arn:aws:kms:eu-west-2:771283872747:key/*",
      "arn:aws:kms:eu-west-2:972272129531:key/*",
      "arn:aws:kms:eu-west-2:004723187462:key/*",
      "arn:aws:kms:eu-west-2:203591025782:key/*",
    ]
  }  
}

resource "aws_iam_policy" "cross_iam_policy_mp" {
  name   = "${var.namespace}-cross-iam-role-mp"
  policy = data.aws_iam_policy_document.cross_iam_policy_mp.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}