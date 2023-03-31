locals {
  name = "terraform-template-poc-state"
}

# S3 Bucket to Store State
module "terraform_template_poc_state_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.1"
  acl    = "private"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "terraform_template_poc_state_bucket" {
  metadata {
    name      = "${local.name}-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.terraform_template_poc_state_bucket.access_key_id
    secret_access_key = module.terraform_template_poc_state_bucket.secret_access_key
    bucket_arn        = module.terraform_template_poc_state_bucket.bucket_arn
  }
}

# DynamoDB State Lock
module "terraform_template_poc_state_lock_table" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.5.1"

  team_name              = var.team_name
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace

  hash_key          = "LockID"
  enable_encryption = "true"
  enable_autoscaler = "true"
}

resource "kubernetes_secret" "terraform_template_poc_state_lock_table" {
  metadata {
    name      = "${local.name}-lock-table"
    namespace = var.namespace
  }

  data = {
    table_name        = module.terraform_template_poc_state_lock_table.table_name
    table_arn         = module.terraform_template_poc_state_lock_table.table_arn
    access_key_id     = module.terraform_template_poc_state_lock_table.access_key_id
    secret_access_key = module.terraform_template_poc_state_lock_table.secret_access_key
  }
}

# IAM user to access S3 and DynamoDB
resource "random_id" "terraform_template_poc_state_id" {
  byte_length = 16
}

resource "aws_iam_user" "terraform_template_poc_state_terraform_user" {
  name = "${local.name}-${random_id.terraform_template_poc_state_id.hex}"
  path = "/system/opseng-terraform-user/"
}

resource "aws_iam_access_key" "terraform_template_poc_state_user" {
  user = aws_iam_user.terraform_template_poc_state_terraform_user.name
}

resource "kubernetes_secret" "terraform_template_poc_state_user_secret" {
  metadata {
    name      = "${local.name}-user-aws-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.terraform_template_poc_state_user.id
    secret_access_key = aws_iam_access_key.terraform_template_poc_state_user.secret
  }
}

data "aws_iam_policy_document" "terraform_template_poc_state_policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]

    resources = [
      module.terraform_template_poc_state_bucket.bucket_arn,
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject",
    ]

    resources = [
      "${module.terraform_template_poc_state_bucket.bucket_arn}/*",
    ]
  }

  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      module.terraform_template_poc_state_lock_table.table_arn,
    ]
  }
}

resource "aws_iam_user_policy" "terraform_template_poc_state_policy" {
  name   = "${local.name}-s3-bucket-and-dynamodb"
  policy = data.aws_iam_policy_document.terraform_template_poc_state_policy.json
  user   = aws_iam_user.terraform_template_poc_state_terraform_user.name
}
