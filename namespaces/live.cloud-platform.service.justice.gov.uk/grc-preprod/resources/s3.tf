module "s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  logging_enabled        = var.logging_enabled
  log_target_bucket      = module.s3_logging_bucket.bucket_name
  log_path               = var.log_path
  enable_allow_block_pub_access = true

  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            module.irsa.role_arn,
            "arn:aws:iam::754256621582:role/cloud-platform-ecr-9eb5479f09a839b9-circleci",
            "arn:aws:iam::754256621582:role/cloud-platform-ecr-00299798fe6401b2-circleci",
            "arn:aws:iam::754256621582:role/cloud-platform-ecr-8319cbbcde12bb45-circleci"
          ]
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
        ]
      },
      {
        Sid = "AllowGetRequestsFromSpecificIPsAndReferers",
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "$${bucket_arn}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" = true
          },
          IpAddress = {
            "aws:SourceIp" = [
              "20.26.11.71/32",
              "20.26.11.108/32",
              "20.49.214.199/32",
              "20.49.214.228/32",
              "51.149.249.0/29",
              "51.149.249.32/29",
              "51.149.250.0/24",
              "128.77.75.64/26",
              "194.33.200.0/21",
              "194.33.216.0/23",
              "194.33.218.0/24",
              "194.33.248.0/29",
              "194.33.249.0/29"
            ]
          },
          StringLike = {
            "aws:Referer" = [
              "https://glimr-preprod.staging.apps.hmcts.net/",
            ]
          }
        }
      }
    ]
  })

  providers = {
    aws = aws.london
  }
}


resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}


#######################################
# s3 bucket for logging all access reqs
#######################################

module "s3_logging_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  bucket_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3ServerAccessLogsPolicy",
        Effect = "Allow",
        Principal = {
          Service = "logging.s3.amazonaws.com"
        },
        Action = [
          "s3:PutObject"
        ],
        Resource = "$${bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            module.irsa.role_arn
          ]
        }
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "kubernetes_secret" "s3_logging_bucket" {
  metadata {
    name      = "s3-logging-bucket-output"
    namespace = var.namespace
  }

  data = {
    BUCKET_ARN  = module.s3_logging_bucket.bucket_arn
    BUCKET_NAME = module.s3_logging_bucket.bucket_name
  }
}