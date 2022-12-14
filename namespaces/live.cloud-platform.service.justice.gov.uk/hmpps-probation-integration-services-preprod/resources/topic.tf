data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd"
}

data "aws_sns_topic" "offender-events" {
  name = "cloud-platform-Digital-Prison-Services-d448bb61bb0b69b82fb19a3fa574e7f9"
}