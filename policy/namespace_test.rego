package main

# Annotations

test_deny_empty_business_unit {
  msg := "Namespace must have business-unit annotation"

  empty_business_unit_annotation := {
    "kind": "Namespace",
    "metadata": {
      "annotations": {
        "cloud-platform.justice.gov.uk/business-unit": "",
        "cloud-platform.justice.gov.uk/application": "sentence-planning",
        "cloud-platform.justice.gov.uk/owner": "Sentence Planning Team: sentence-plan-team@digital.justice.gov.uk",
        "cloud-platform.justice.gov.uk/source-code": "https://github.com/ministryofjustice/sentence-planning.git",
        "cloud-platform.justice.gov.uk/slack-channel": "peoplefinder",
      }
    }
  }

  deny[msg] with input as empty_business_unit_annotation
}

test_deny_missing_application {
  msg := "Namespace must have application annotation"

  missing_application_annotation := {
    "kind": "Namespace",
    "metadata": {
      "annotations": {
        "cloud-platform.justice.gov.uk/business-unit": "HMPPS",
        "cloud-platform.justice.gov.uk/owner": "Sentence Planning Team: sentence-plan-team@digital.justice.gov.uk",
        "cloud-platform.justice.gov.uk/source-code": "https://github.com/ministryofjustice/sentence-planning.git",
        "cloud-platform.justice.gov.uk/slack-channel": "peoplefinder",
      }
    }
  }

  deny[msg] with input as missing_application_annotation
}

# Business unit

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

test_not_deny_valid_busines_unit {
  msg := "Invalid business-unit annotation: HMPPS"

  good_business_unit := {
    "kind": "Namespace",
    "metadata": {
      "annotations": {
        "cloud-platform.justice.gov.uk/business-unit": "HMPPS",
      }
    }
  }

  not deny[msg] with input as good_business_unit
}
