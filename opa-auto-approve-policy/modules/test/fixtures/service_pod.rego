package test.terraform.analysis

sp_mock_tfplan := {
    "variables": {
        "namespace": {
            "value": "testing-ns"
        }
    },
    "resource_changes": [
        {
            "address": "module.irsa_1.kubernetes_service_account.generated_sa",
            "module_address": "module.irsa_1",
            "type": "kubernetes_service_account",
            "name": "generated_sa",
            "change": {
                "actions": [
                    "no-op"
                ],
                "after": {
                    "metadata": [
                        {
                            "name": "testing-sa-1",
                            "namespace": "testing-ns"
                        }
                    ]
                }
            }
        },
        {
            "address": "module.irsa_2.kubernetes_service_account.generated_sa",
            "module_address": "module.irsa_2",
            "type": "kubernetes_service_account",
            "name": "generated_sa",
            "change": {
                "actions": [
                    "no-op"
                ],
                "after": {
                    "metadata": [
                        {
                            "name": "testing-sa-2",
                            "namespace": "testing-ns"
                        }
                    ]
                }
            }
        },
        {
            "address": "module.service_pod_1.kubernetes_deployment.service_pod",
            "module_address": "module.service_pod_1",
            "type": "kubernetes_deployment",
            "name": "service_pod",
            "change": {
                "actions": [
                    "create"
                ],
                "after": {
                    "metadata": [
                        {
                            "name": "testing-sa-service-pod",
                            "namespace": "testing-ns"
                        }
                    ],
                    "spec": [
                        {
                            "template": [
                                {
                                    "spec": [
                                        {
                                            "service_account_name": "testing-sa-1"
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            }
        },
        {
            "address": "module.service_pod_2.kubernetes_deployment.service_pod",
            "module_address": "module.service_pod_2",
            "type": "kubernetes_deployment",
            "name": "service_pod",
            "change": {
                "actions": [
                    "create"
                ],
                "after": {
                    "metadata": [
                        {
                            "name": "testing-sa-service-pod",
                            "namespace": "testing-ns"
                        }
                    ],
                    "spec": [
                        {
                            "template": [
                                {
                                    "spec": [
                                        {
                                            "service_account_name": "testing-sa-2"
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            }
        },
        {
            "address": "module.service_pod_1.random_id.name",
            "module_address": "module.service_pod_1",
            "mode": "managed",
            "type": "random_id",
            "name": "name",
            "provider_name": "registry.terraform.io/hashicorp/random",
            "change": {
                "actions": [
                    "create"
                ],
                "before": null,
                "after": {
                    "byte_length": 8,
                    "keepers": null,
                    "prefix": null
                }
            }
        },
        {
            "address": "module.service_pod_2.random_id.name",
            "module_address": "module.service_pod_2",
            "mode": "managed",
            "type": "random_id",
            "name": "name",
            "provider_name": "registry.terraform.io/hashicorp/random",
            "change": {
                "actions": [
                    "create"
                ],
                "before": null,
                "after": {
                    "byte_length": 8,
                    "keepers": null,
                    "prefix": null
                }
            }
        }
    ]
}