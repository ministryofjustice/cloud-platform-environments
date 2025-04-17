package test.terraform.analysis

mock_tfplan := {
	"variables": {"namespace": {"value": "jaskaran-dev"}},
	"resource_changes": [{
		"address": "kubernetes_secret.jasky-test",
		"mode": "managed",
		"type": "kubernetes_secret",
		"name": "jasky-test",
		"provider_name": "registry.terraform.io/hashicorp/kubernetes",
		"change": {
			"actions": ["create"],
			"before": null,
			"after": {
				"binary_data": null,
				"binary_data_wo": null,
				"binary_data_wo_revision": null,
				"data": {"url": "test.com"},
				"data_wo": null,
				"data_wo_revision": null,
				"immutable": null,
				"metadata": [{
					"annotations": null,
					"generate_name": null,
					"labels": null,
					"name": "j-secret",
					"namespace": "jaskaran-dev",
				}],
				"timeouts": null,
				"type": "Opaque",
				"wait_for_service_account_token": true,
			},
			"after_unknown": {
				"data": {},
				"id": true,
				"metadata": [{
					"generation": true,
					"resource_version": true,
					"uid": true,
				}],
			},
			"before_sensitive": false,
			"after_sensitive": {
				"binary_data": true,
				"data": true,
				"metadata": [{}],
			},
		},
	}],
}

mock_tfplan_v1 := {
	"variables": {"namespace": {"value": "jaskaran-dev"}},
	"resource_changes": [{
		"address": "kubernetes_secret.jasky-test",
		"mode": "managed",
		"type": "kubernetes_secret_v1",
		"name": "jasky-test",
		"provider_name": "registry.terraform.io/hashicorp/kubernetes",
		"change": {
			"actions": ["create"],
			"before": null,
			"after": {
				"binary_data": null,
				"binary_data_wo": null,
				"binary_data_wo_revision": null,
				"data": {"url": "test.com"},
				"data_wo": null,
				"data_wo_revision": null,
				"immutable": null,
				"metadata": [{
					"annotations": null,
					"generate_name": null,
					"labels": null,
					"name": "j-secret",
					"namespace": "jaskaran-dev",
				}],
				"timeouts": null,
				"type": "Opaque",
				"wait_for_service_account_token": true,
			},
			"after_unknown": {
				"data": {},
				"id": true,
				"metadata": [{
					"generation": true,
					"resource_version": true,
					"uid": true,
				}],
			},
			"before_sensitive": false,
			"after_sensitive": {
				"binary_data": true,
				"data": true,
				"metadata": [{}],
			},
		},
	}],
}

mock_tfplan_invalid := {
	"variables": {"namespace": {"value": "jaskaran-dev"}},
	"resource_changes": [
		{
			"address": "kubernetes_secret.jasky-test",
			"mode": "managed",
			"type": "kubernetes_secret",
			"name": "jasky-test",
			"provider_name": "registry.terraform.io/hashicorp/kubernetes",
			"change": {
				"actions": ["create"],
				"before": null,
				"after": {
					"binary_data": null,
					"binary_data_wo": null,
					"binary_data_wo_revision": null,
					"data": {"url": "test.com"},
					"data_wo": null,
					"data_wo_revision": null,
					"immutable": null,
					"metadata": [{
						"annotations": null,
						"generate_name": null,
						"labels": null,
						"name": "j-secret",
						"namespace": "jaskaran-dev",
					}],
					"timeouts": null,
					"type": "Opaque",
					"wait_for_service_account_token": true,
				},
				"after_unknown": {
					"data": {},
					"id": true,
					"metadata": [{
						"generation": true,
						"resource_version": true,
						"uid": true,
					}],
				},
				"before_sensitive": false,
				"after_sensitive": {
					"binary_data": true,
					"data": true,
					"metadata": [{}],
				},
			},
		},
		{
			"address": "kubernetes_secret.jasky-test",
			"mode": "managed",
			"type": "kubernetes_secret_v1",
			"name": "jasky-test",
			"provider_name": "registry.terraform.io/hashicorp/kubernetes",
			"change": {
				"actions": ["create"],
				"before": null,
				"after": {
					"binary_data": null,
					"binary_data_wo": null,
					"binary_data_wo_revision": null,
					"data": {"url": "test.com"},
					"data_wo": null,
					"data_wo_revision": null,
					"immutable": null,
					"metadata": [{
						"annotations": null,
						"generate_name": null,
						"labels": null,
						"name": "j-secret",
						"namespace": "wrong",
					}],
					"timeouts": null,
					"type": "Opaque",
					"wait_for_service_account_token": true,
				},
				"after_unknown": {
					"data": {},
					"id": true,
					"metadata": [{
						"generation": true,
						"resource_version": true,
						"uid": true,
					}],
				},
				"before_sensitive": false,
				"after_sensitive": {
					"binary_data": true,
					"data": true,
					"metadata": [{}],
				},
			},
		},
	],
}
