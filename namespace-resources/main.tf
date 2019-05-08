locals {
  cluster = "live-1.cloud-platform.service.justice.gov.uk"
}

data "template_file" "namespace" {
  template = "${file("${path.module}/00-namespace.yaml")}"

  vars {
    namespace       = "${var.namespace}"
    business-unit   = "${var.business-unit}"
    is-production   = "${var.is-production}"
    environment     = "${var.environment}"
    application     = "${var.application}"
    owner           = "${var.owner}"
    contact_email   = "${var.contact_email}"
    source_code_url = "${var.source_code_url}"
  }
}

resource "local_file" "00-namespace" {
  content  = "${data.template_file.namespace.rendered}"
  filename = "../namespaces/${local.cluster}/${var.namespace}/00-namespace.yaml"
}

data "template_file" "rbac" {
  template = "${file("${path.module}/01-rbac.yaml")}"

  vars {
    namespace   = "${var.namespace}"
    github_team = "${var.github_team}"
  }
}

resource "local_file" "01-rbac" {
  content  = "${data.template_file.rbac.rendered}"
  filename = "../namespaces/${local.cluster}/${var.namespace}/01-rbac.yaml"
}

data "template_file" "limitrange" {
  template = "${file("${path.module}/02-limitrange.yaml")}"

  vars {
    namespace = "${var.namespace}"
  }
}

resource "local_file" "02-limitrange" {
  content  = "${data.template_file.limitrange.rendered}"
  filename = "../namespaces/${local.cluster}/${var.namespace}/02-limitrange.yaml"
}

data "template_file" "resourcequota" {
  template = "${file("${path.module}/03-resourcequota.yaml")}"

  vars {
    namespace = "${var.namespace}"
  }
}

resource "local_file" "03-resourcequota" {
  content  = "${data.template_file.resourcequota.rendered}"
  filename = "../namespaces/${local.cluster}/${var.namespace}/03-resourcequota.yaml"
}

data "template_file" "networkpolicy" {
  template = "${file("${path.module}/04-networkpolicy.yaml")}"

  vars {
    namespace = "${var.namespace}"
  }
}

resource "local_file" "04-networkpolicy" {
  content  = "${data.template_file.networkpolicy.rendered}"
  filename = "../namespaces/${local.cluster}/${var.namespace}/04-networkpolicy.yaml"
}

resource "local_file" "resources-main-tf" {
  content  = "${file("${path.module}/resources-main-tf")}"
  filename = "../namespaces/${local.cluster}/${var.namespace}/resources/main.tf"
}
