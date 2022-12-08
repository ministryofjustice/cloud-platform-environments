module "ap_irsa" {
  source           = "/Users/vijay.veeranki/moj/cloud-platform-terraform-irsa"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = [aws_iam_policy.ap_policy.arn]
  service_account  = "${var.namespace}-to-ap-s3"
}

resource "aws_iam_policy" "ap_policy" {
  name   = "${var.namespace}-ap-policy"
  policy = data.aws_iam_policy_document.ap_access.json
}

data "aws_iam_policy_document" "ap_access" {
  statement {
    sid = "AllowRdsExportUserToListS3Buckets"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }

}
