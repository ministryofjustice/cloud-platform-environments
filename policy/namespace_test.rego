package main

test_deny_invalid_busines_unit {
  msg := "Invalid business-unit annotation: invalid-business-unit"

  bad_business_unit := {
    "kind": "Namespace",
    "metadata": {
      "annotations": {
        "cloud-platform.justice.gov.uk/business-unit": "invalid-business-unit",
      }
    }
  }

  deny[msg] with input as bad_business_unit
}
