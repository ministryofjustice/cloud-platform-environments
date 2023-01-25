resource "aws_s3_bucket" "truststore" {
  bucket = "${var.namespace}-truststore"
}

resource "aws_s3_bucket_versioning" "truststore" {
  bucket = aws_s3_bucket.truststore.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "truststore" {
  bucket = aws_s3_bucket.truststore.bucket
  key    = "truststore.pem"
  source = "truststore.pem"

  etag = filemd5("./truststore.pem")
}
