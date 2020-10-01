package main

# Policy definitions that all namespaces defined in this repository should comply with.

allowed_business_units := [
  "CICA",
  "HMCTS",
  "HMPPS",
  "HQ",
  "LAA",
  "OPG",
  "Platforms"
]

# Annotations

has_cp_annotation(annotation) {
  cp_annotation := concat("/", ["cloud-platform.justice.gov.uk", annotation])
  input.metadata.annotations[cp_annotation]
  input.metadata.annotations[cp_annotation] != ""
}

has_cp_label(label) {
  cp_label := concat("/", ["cloud-platform.justice.gov.uk", label])
  input.metadata.labels[cp_label]
  input.metadata.labels[cp_label] != ""
}

deny[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("business-unit")
  msg := "Namespace must have business-unit annotation"
}

deny[msg] {
  input.kind == "Namespace"
  annotation := input.metadata.annotations["cloud-platform.justice.gov.uk/business-unit"]
  not array_contains(allowed_business_units, annotation)
  msg := sprintf("Invalid business-unit annotation: %s", [annotation])
}

deny[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("application")
  msg := "Namespace must have application annotation"
}

deny[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("owner")
  msg := "Namespace must have owner annotation"
}

deny[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("source-code")
  msg := "Namespace must have source-code annotation"
}

deny[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("slack-channel")
  msg := "Namespace must have slack-channel annotation"
}

# Labels

deny[msg] {
  input.kind == "Namespace"
  not has_cp_label("is-production")
  msg := "Namespace must have is-production label"
}

deny[msg] {
  input.kind == "Namespace"
  not has_cp_label("environment-name")
  msg := "Namespace must have environment-name label"
}
