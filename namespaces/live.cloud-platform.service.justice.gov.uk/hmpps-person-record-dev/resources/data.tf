data "aws_ssm_parameter" "court-cases-topic-arn" {
  name = "/court-probation-dev/court-cases-topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-dev/topic-arn"
}

data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573"
}

data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-453cac1179377186788c5fcd12525870"
}

data "aws_ssm_parameter" "large-court-cases-s3-credentials" {
  name = "/court-probation-dev/large-court-cases-s3-credentials"
}

