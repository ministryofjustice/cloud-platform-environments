/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {
}


variable "namespace" {
  default = "track-a-query-metabase"
}


variable "is-production" {
  default = "true"
}

variable "environment-name" {
  default = "production"
}

