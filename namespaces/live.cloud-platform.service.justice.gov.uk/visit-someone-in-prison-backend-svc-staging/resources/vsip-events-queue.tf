######################################## Prison visits event for visit someone in prison
######## hmpps-manage-prison-visits-orchestration service should listen to the configured queue (hmpps_prison_visits_event_queue)
######## for the given fevents (filter_policy configured below)!

######## BECAUSE THIS IS STAGING WE DO NOT SUBSCRIBE TO THE DOMAIN EVENTS QUEUE

######## Main queue

module "hmpps_prison_visits_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name           = var.environment
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "hmpps_prison_visits_event_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  namespace                  = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_prison_visits_event_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
EOF
  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_event_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-event-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-staging"
  }

  data = {
    access_key_id     = module.hmpps_prison_visits_event_queue.access_key_id
    secret_access_key = module.hmpps_prison_visits_event_queue.secret_access_key
    sqs_queue_url     = module.hmpps_prison_visits_event_queue.sqs_id
    sqs_queue_arn     = module.hmpps_prison_visits_event_queue.sqs_arn
    sqs_queue_name    = module.hmpps_prison_visits_event_queue.sqs_name
  }
}


######## Dead letter queue

module "hmpps_prison_visits_event_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_prison_visits_event_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prison_visits_event_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-prison-visits-event-dlq-secret"
    ## Name space where the listening service is found
    namespace = "visit-someone-in-prison-backend-svc-staging"
  }

  data = {
    access_key_id     = module.hmpps_prison_visits_event_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_prison_visits_event_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.hmpps_prison_visits_event_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.hmpps_prison_visits_event_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.hmpps_prison_visits_event_dead_letter_queue.sqs_name
  }
}
