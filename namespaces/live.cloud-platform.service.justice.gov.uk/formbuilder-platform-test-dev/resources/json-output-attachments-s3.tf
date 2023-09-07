module "json-output-attachments-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.9.0"

  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = "transformed-department"
  application            = "formbuilderuserfilestore"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  user_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:PutObject"
    ],
    "Resource": "$${bucket_arn}/*"
  }
]
}
EOF


  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-7d"
      prefix                                 = "7d/"
      abort_incomplete_multipart_upload_days = 7
      expiration = [
        {
          days = 7
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]
    },
  ]
}

module "json-output-attachments-s3-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name = var.eks_cluster_name

  service_account_name = "json-output-attachments-irsa-${var.environment-name}"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    jsonS3       = module.json-output-attachments-s3-bucket.irsa_policy_arn
  }

  team_name              = var.team_name
  business_unit          = "transformed-department"
  application            = "formbuilderuserfilestore"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "json-output-attachments-s3-bucket-cross-namespace" {
  metadata {
    name      = "json-output-s3-arn"
    namespace = "formbuilder-saas-test"
  }

  data = {
    s3_policy_arn = module.json-output-attachments-s3-irsa.irsa_policy_arn
  }
}

resource "kubernetes_secret" "json-output-attachments-s3-bucket" {
  metadata {
    name      = "json-output-attachments-s3-bucket-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    access_key_id     = module.json-output-attachments-s3-bucket.access_key_id
    bucket_arn        = module.json-output-attachments-s3-bucket.bucket_arn
    bucket_name       = module.json-output-attachments-s3-bucket.bucket_name
    secret_access_key = module.json-output-attachments-s3-bucket.secret_access_key
  }
}
