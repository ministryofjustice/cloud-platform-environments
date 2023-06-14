
    module "irsa" {
      source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
      namespace        = "${var.namespace}"
      role_policy_arns = ["<aws_iam_policy.${var.namespace}_<policy_name>.arn>"]
    }
    data "aws_iam_policy_document" "${var.namespace}_<policy_name>" {
      # Provide list of permissions and target AWS account resources to allow access to
      statement {
        actions = [
          "s3:PutObject",
          "s3:PutObjectAcl",
        ]
        resources = [
          "<ARN of resource in target AWS account>/*",
        ]
      }
    }
    resource "aws_iam_policy" "${var.namespace}_<policy_name>" {
      name   = "${var.namespace}-<policy-name>"
      policy = data.aws_iam_policy_document.${var.namespace}_<policy_name>.json

      tags = {
        business-unit          = "<Which part of the MoJ is responsible for this service? (e.g HMPPS, Legal Aid Agency)>"
        application            = "<Application name>"
        is-production          = "<true/false>"
        environment-name       = "<dev/test/staging/prod>"
        owner                  = "<team responsible for this application>"
        infrastructure-support = "<Email address for contact/support>"
      }
    }
    resource "kubernetes_secret" "irsa" {
      metadata {
        name      = "irsa-output"
        namespace = "${var.namespace}"
      }
      data = {
        role = module.irsa.aws_iam_role_name
        serviceaccount = module.irsa.service_account_name.name
      }
    }

