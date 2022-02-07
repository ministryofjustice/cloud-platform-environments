resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  count       = length(local.suppliers)
  name        = "${local.suppliers[count.index]}${var.environment_suffix}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = module.track_a_move_s3_bucket.bucket_arn
    buffer_size         = 5
    buffer_interval     = 300
    prefix              = "${local.suppliers[count.index]}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "error/"
  }

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "${var.namespace}-firehose"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy" {
  name = "firehose_write_s3"

  role = aws_iam_role.firehose_role.name

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${module.track_a_move_s3_bucket.bucket_arn}",
        "${module.track_a_move_s3_bucket.bucket_arn}/*"
      ]
    }
  ]
}
EOF
}
