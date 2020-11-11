resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "terraform-kinesis-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = module.track_a_move_s3_bucket.bucket_arn
    buffer_size         = 5
    buffer_interval     = 300
    prefix              = "prefix1/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "error/"
  }
}


resource "aws_iam_role" "firehose_role" {
  name = "firehose_assume_role"

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
