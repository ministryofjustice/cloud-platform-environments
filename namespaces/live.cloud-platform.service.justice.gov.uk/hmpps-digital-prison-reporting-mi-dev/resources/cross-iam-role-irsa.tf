module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name     = "var.eks_cluster_name"
  service_account_name = "dpr-reporting-mi-${var.environment}-cross-iam"
  namespace            = var.namespace
  role_policy_arns     = [aws_iam_policy.cross_iam_role_mp.arn]
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
  }
}

resource "aws_iam_policy" "cross_iam_role_mp" {
  name   = "${var.namespace}-cross-iam-role-mp"
  policy = data.aws_iam_policy_document.cross_iam_policy_mp.json

  tags = {
    business-unit          = "HMPPS"
    application            = "Digital Prison Reporting Management Information"
    is-production          = "false"
    environment-name       = "development"
    owner                  = "hmpps-digital-prison-reporting"
    infrastructure-support = "platforms@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role = module.irsa.aws_iam_role_name
    serviceaccount = module.irsa.service_account_name.name
  }
}