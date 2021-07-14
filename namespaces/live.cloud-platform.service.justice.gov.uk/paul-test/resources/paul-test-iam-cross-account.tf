module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.6.4"

  namespace        = "paul-test"
  role_policy_arns = ["arn:aws:iam::754256621582:policy/paul-test-iam-policy"]
  service_account  = "paul-test"
}
data "aws_iam_policy_document" "paul-test" {
  # "api" policy statements for "paul-test" namespace


  # allows direct access to "landing" S3 bucket for Prison Network App in mojap AWS account
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::paul-test-cross-account-iam/*",
    ]
  }
}

resource "aws_iam_policy" "paul-test" {
  name   = "paul-test-iam-policy"
  policy = data.aws_iam_policy_document.paul-test.json
}
