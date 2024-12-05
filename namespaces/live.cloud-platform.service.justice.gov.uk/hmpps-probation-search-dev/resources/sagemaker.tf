module "sagemaker_model_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"

  bucket_name            = "${var.namespace}-sagemaker-model-bucket"
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${var.namespace}-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "s3"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:ListBucket"]
          Resource = [module.sagemaker_model_bucket.bucket_arn, "${module.sagemaker_model_bucket.bucket_arn}/*"]
        }
      ]
    })
  }
}

resource "aws_sagemaker_model" "huggingface_embedding_model" {
  name               = "${var.namespace}-sagemaker-hf-model"
  execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

  primary_container {
    image = "764974769150.dkr.ecr.eu-west-2.amazonaws.com/tei:2.0.1-tei1.2.3-gpu-py310-cu122-ubuntu22.04"
    environment = {
      HF_MODEL_ID = "mixedbread-ai/mxbai-embed-large-v1"
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "config" {
  name = "${var.namespace}-sagemaker-endpoint-config"
  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.huggingface_embedding_model.name
    initial_instance_count = 1
    instance_type          = "ml.g5.2xlarge"
  }
}

resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = "${var.namespace}-sagemaker-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.config.name
}
