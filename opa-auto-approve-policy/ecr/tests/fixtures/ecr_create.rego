package test.terraform.analysis

ecr_create_mock_tfplan := {
    "resource_changes": [
        {
            "address": "module.ecr_2.aws_ecr_repository.repo",
            "module_address": "module.ecr_2",
            "mode": "managed",
            "type": "aws_ecr_repository",
            "name": "repo",
            "provider_name": "registry.terraform.io/hashicorp/aws",
            "change": {
                "actions": [
                    "create"
                ],
                "before": null,
                "after": {
                    "encryption_configuration": [],
                    "force_delete": false,
                    "image_scanning_configuration": [
                        {
                            "scan_on_push": true
                        }
                    ],
                    "image_tag_mutability": "MUTABLE",
                    "name": "mikebell-test",
                    "tags": {
                        "application": "mikebell-test",
                        "business-unit": "Platforms",
                        "environment-name": "development",
                        "infrastructure-support": "cloudplatform@digital.justice.gov.uk",
                        "is-production": "false",
                        "namespace": "mikebell-test",
                        "owner": "mikebell-test"
                    },
                    "tags_all": {
                        "application": "mikebell-test",
                        "business-unit": "Platforms",
                        "environment-name": "development",
                        "infrastructure-support": "cloudplatform@digital.justice.gov.uk",
                        "is-production": "false",
                        "namespace": "mikebell-test",
                        "owner": "mikebell-test",
                        "slack-channel": "cloud-platform-test",
                        "source-code": "github.com/ministryofjustice/cloud-platform-environments"
                    },
                    "timeouts": null
                },
                "after_unknown": {
                    "arn": true,
                    "encryption_configuration": [],
                    "id": true,
                    "image_scanning_configuration": [
                        {}
                    ],
                    "registry_id": true,
                    "repository_url": true,
                    "tags": {},
                    "tags_all": {}
                },
                "before_sensitive": false,
                "after_sensitive": {
                    "encryption_configuration": [],
                    "image_scanning_configuration": [
                        {}
                    ],
                    "tags": {},
                    "tags_all": {}
                }
            }
        }
    ]
}