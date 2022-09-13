{
    "policy": {
        "description": "hot-warm-cold-delete",
        "default_state": "hot",
        "states": [
            {
                "name": "hot",
                "actions": [],
                "transitions": [
                    {
                        "state_name": "warm",
                        "conditions": {
                            "min_index_age": "${warm_transition}"
                        }
                    }
                ]
            },
            {
                "name": "warm",
                "actions": [
                    {
                        "warm_migration": {},
                        "retry": {
                            "count": 3,
                            "delay": "1h",
                            "backoff": "exponential"
                        }
                    }
                ],
                "transitions": [
                    {
                        "state_name": "cold",
                        "conditions": {
                            "min_index_age": "${cold_transition}"
                        }
                    }
                ]
            },
            {
                "name": "cold",
                "actions": [
                    {
                        "cold_migration": {
                            "timestamp_field": "${timestamp_field}",
                            "end_time": null,
                            "ignore": "none",
                            "start_time": null
                        },
                        "retry": {
                            "count": 3,
                            "delay": "1h",
                            "backoff": "exponential"
                        }
                    }
                ],
                "transitions": [
                    {
                        "state_name": "delete",
                        "conditions": {
                            "min_index_age": "${delete_transition}"
                        }
                    }
                ]
            },
            {
                "name": "delete",
                "actions": [
                    {
                        "cold_delete": {},
                        "retry": {
                            "count": 3,
                            "delay": "1h",
                            "backoff": "exponential"
                        }
                    }
                ],
                "transitions": []
            }
        ],
        "ism_template": [
            {
                "index_patterns": ${index_pattern},
                "priority": 100
            }
        ]
    }
}