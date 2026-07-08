package main
import future.keywords.if

# Policy definitions that all namespaces defined in this repository should comply with.

allowed_business_units := [
  "Central Digital",
  "CICA",
  "HMCTS",
  "HMPPS",
  "HQ",
  "LAA",
  "OPG",
  "Platforms",
  "Technology Services"
]

# Annotations

has_cp_annotation(annotation) if {
  cp_annotation := concat("/", ["cloud-platform.justice.gov.uk", annotation])
  input.metadata.annotations[cp_annotation]
  input.metadata.annotations[cp_annotation] != ""
}

has_cp_label(label) if {
  cp_label := concat("/", ["cloud-platform.justice.gov.uk", label])
  input.metadata.labels[cp_label]
  input.metadata.labels[cp_label] != ""
}

deny_namespace_no_business_unit[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("business-unit")
  msg := "Namespace must have business-unit annotation"
}

deny_namespace_invalid_business_unit[msg] {
  input.kind == "Namespace"
  annotation := input.metadata.annotations["cloud-platform.justice.gov.uk/business-unit"]
  not array_contains(allowed_business_units, annotation)
  msg := sprintf("Invalid business-unit annotation: %s", [annotation])
}

deny_namespace_no_application[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("application")
  msg := "Namespace must have application annotation"
}

deny_namespace_no_owner[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("owner")
  msg := "Namespace must have owner annotation"
}

deny_namespace_no_source_code[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("source-code")
  msg := "Namespace must have source-code annotation"
}

deny_namespace_no_slack_channel[msg] {
  input.kind == "Namespace"
  not has_cp_annotation("slack-channel")
  msg := "Namespace must have slack-channel annotation"
}

# Labels

deny_namespace_no_is_production[msg] {
  input.kind == "Namespace"
  not has_cp_label("is-production")
  msg := "Namespace must have is-production label"
}

deny_namespace_no_environment_name[msg] {
  input.kind == "Namespace"
  not has_cp_label("environment-name")
  msg := "Namespace must have environment-name label"
}

deny_namespace_no_psa[msg] {
  input.kind == "Namespace"
  not input.metadata.labels["pod-security.kubernetes.io/enforce"] == "restricted"
  msg := "Namespace must have label 'pod-security.kubernetes.io/enforce: restricted'"
}

deny_namespace_no_alerts[msg] {
  input.kind == "Namespace"
  input.metadata.labels["component"] == "cloud-platform-monitoring-alerts"
  msg := "Namespace must not have label 'component: cloud-platform-monitoring-alerts'"
}
