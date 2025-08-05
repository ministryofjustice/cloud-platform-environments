module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = "live"

  # IRSA configuration
  service_account_name = "irsa-sqs-${var.namespace}"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    sqs = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSQSActions",
      "Effect": "Allow",
      "Action": [
        "sqs:*"
      ],
      "Resource": "${data.aws_ssm_parameter.sqs_queue_arn.value}"
    }
  ]
}
EOF
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}

resource "kubernetes_secret" "sqs_queue_arn" {
  metadata {
    name      = "${var.namespace}-sqs-arn"
    namespace = var.namespace
  }
  data = {
    arn = data.aws_ssm_parameter.sqs_queue_arn.value
  }
}