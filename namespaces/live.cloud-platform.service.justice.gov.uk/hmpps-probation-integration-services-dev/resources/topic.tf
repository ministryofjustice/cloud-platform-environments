data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573"
}

data "aws_sns_topic" "offender-events" {
  name = "cloud-platform-Digital-Prison-Services-f221e27fcfcf78f6ab4f4c3cc165eee7"
}