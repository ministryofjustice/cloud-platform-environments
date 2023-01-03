data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08"
}

data "aws_sns_topic" "offender-events" {
  name = "cloud-platform-Digital-Prison-Services-160f3055cc4e04c4105ee85f2ed1fccb"
}