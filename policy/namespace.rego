package main

# Policy definitions that all namespaces defined in this repository should comply with.

# Annotations

deny[msg] {
  input.kind == "Namespace"
  not input.metadata.annotations["cloud-platform.justice.gov.uk/business-unit"]
  msg := "Namespace must have business-unit annotation"
}

deny[msg] {
  input.kind == "Namespace"
  not input.metadata.annotations["cloud-platform.justice.gov.uk/application"]
  msg := "Namespace must have application annotation"
}

deny[msg] {
  input.kind == "Namespace"
  not input.metadata.annotations["cloud-platform.justice.gov.uk/owner"]
  msg := "Namespace must have owner annotation"
}

deny[msg] {
  input.kind == "Namespace"
  not input.metadata.annotations["cloud-platform.justice.gov.uk/source-code"]
  msg := "Namespace must have source-code annotation"
}

deny[msg] {
  input.kind == "Namespace"
  not input.metadata.annotations["cloud-platform.justice.gov.uk/slack-channel"]
  msg := "Namespace must have slack-channel annotation"
}

# Labels

deny[msg] {
  input.kind == "Namespace"
  not input.metadata.labels["cloud-platform.justice.gov.uk/is-production"]
  msg := "Namespace must have is-production label"
}

deny[msg] {
  input.kind == "Namespace"
  not input.metadata.labels["cloud-platform.justice.gov.uk/environment-name"]
  msg := "Namespace must have environment-name label"
}

