module "s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = var.versioning

  lifecycle_rule = [
    {
      id      = "${var.environment_name}-lifecycle-rule"
      enabled = false

      noncurrent_version_transition = [
        {
          days          = var.s3_lifecycle_config["noncurrent_version_transition_days"]
          storage_class = "STANDARD_IA"
        },
        {
          days          = var.s3_lifecycle_config["noncurrent_version_transition_glacier_days"]
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = [
        {
          days = var.s3_lifecycle_config["noncurrent_version_expiration_days"]
        },
      ]
    },
    {
      id      = "Expire current objects"
      enabled = true

      expiration = [
        {
          days = 1
        }
      ]

      # expire previous versions
      noncurrent_version_expiration = [
        {
          days = 1
        }
      ]
    },
    {
      id      = "Clean up delete markers"
      enabled = true

      expiration = [
        {
          expired_object_delete_marker = true
        }
      ]
    },
    {
      id      = "Abort incomplete uploads automatically"
      enabled = true
      abort_incomplete_multipart_upload = [
        {
          days_after_initiation = 1
        }
      ]
    }
  ]
}

resource "aws_s3_bucket_accelerate_configuration" "this" {
  bucket = module.s3_bucket.bucket_name
  status = "Enabled"
}

resource "aws_iam_user" "alfresco_user" {
  name = "${var.namespace}-alfresco_user"
  path = "/system/${var.namespace}-alfresco_user/"
}

resource "aws_iam_access_key" "alfresco_user_access" {
  user = aws_iam_user.alfresco_user.name
}

resource "aws_iam_user_policy_attachment" "alfresco_user_policy" {
  policy_arn = module.s3_bucket.irsa_policy_arn
  user       = aws_iam_user.alfresco_user.name
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    BUCKET_ARN  = module.s3_bucket.bucket_arn
    BUCKET_NAME = module.s3_bucket.bucket_name
    ACCESSKEY   = aws_iam_access_key.alfresco_user_access.id
    SECRETKEY   = aws_iam_access_key.alfresco_user_access.secret
  }
}

module "s3_bucket_v2" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = var.versioning
  bucket_name            = "delius-alfresco-${var.environment_name}-s3-storage"

  lifecycle_rule = [
    {
      id      = "${var.environment_name}-lifecycle-rule"
      enabled = false

      noncurrent_version_transition = [
        {
          days          = var.s3_lifecycle_config["noncurrent_version_transition_days"]
          storage_class = "STANDARD_IA"
        },
        {
          days          = var.s3_lifecycle_config["noncurrent_version_transition_glacier_days"]
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = [
        {
          days = var.s3_lifecycle_config["noncurrent_version_expiration_days"]
        },
      ]
    }
  ]
}

resource "aws_s3_bucket_accelerate_configuration" "s3_accl_config" {
  bucket = module.s3_bucket_v2.bucket_name
  status = "Enabled"
}

resource "aws_iam_user" "alfresco_user_v2" {
  name = "${var.namespace}-alfresco_user_v2"
  path = "/system/${var.namespace}-alfresco_user_v2/"
}

resource "aws_iam_access_key" "alfresco_user_access_v2" {
  user = aws_iam_user.alfresco_user_v2.name
}

resource "aws_iam_user_policy_attachment" "alfresco_user_policy_v2" {
  policy_arn = module.s3_bucket_v2.irsa_policy_arn
  user       = aws_iam_user.alfresco_user_v2.name
}

resource "kubernetes_secret" "s3_bucket_v2" {
  metadata {
    name      = "alf-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    BUCKET_ARN  = module.s3_bucket_v2.bucket_arn
    BUCKET_NAME = module.s3_bucket_v2.bucket_name
    ACCESSKEY   = aws_iam_access_key.alfresco_user_access_v2.id
    SECRETKEY   = aws_iam_access_key.alfresco_user_access_v2.secret
  }
}
