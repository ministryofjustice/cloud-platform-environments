# OPA Auto Approve Policy for Terraform PRs

## Overview

The **OPA Auto Approve Policy** framework automates the validation and approval of Terraform pull requests (PRs). This framework ensures compliance with predefined rules and security standards before auto-approving changes to the infrastructure.

### Key Workflows

1. **OPA Validation Against Terraform Plans**:
   - Validates PRs with Terraform changes using the `plan-live` job in the Concourse CI pipeline.
   - Automatically approves compliant changes or flags them for manual review.

2. **OPA Policy Testing**:
   - Uses the `opa-app-test.yml` GitHub Action in the `cloud-platform-environments` repository.
   - Validates the OPA auto-approve policies to ensure they work as expected.

## How It Works

### OPA Validation Against Terraform Plans Steps:

1. **Terraform Plan Generation**:
   - The `cloud-platform-cli` command generates a Terraform plan (`plan-<namespace>.out`) for the PR changes.

2. **Plan Conversion**:
   - The Terraform plan binary is converted to a JSON format for policy validation.

3. **OPA Policy Validation**:
   - The JSON output is evaluated against OPA policies:
     - Ensures adherence to OPA auto-approve policies.
     - Confirms no YAML file changes exist outside the `resources/` directory of the namespace.

4. **PR Review and Approval**:
   - **If Validation Passes**:
     - The PR is automatically approved using the GitHub API.
   - **If Validation Fails**:
     - A comment is added to the PR with failure reasons and a request for manual review.

## Policy Structure

The policy framework is modular for scalability and maintainability:

```
opa-auto-approve-policy
├── README.md
├── main.rego
└── modules
    ├── service_pod.rego
    └── test
        ├── fixtures
        │   └── service_pod.rego
        └── service_pod_test.rego
```

### Key Components

1. **`main.rego`**:
   - The primary entry point for the OPA policy, containing the overarching logic for auto-approval.

2. **`modules/`**:
   - This folder contains resource-specific modules, each focusing on validating a specific resource type.
   - Example: `service_pod.rego` handles validation for service pods module deploymet.

3. **Tests and Fixtures**:
   - Each module includes:
     - **Test File**: Validates the module’s OPA logic (e.g., `service_pod_test.rego`).
     - **Fixtures**: Mock Terraform plan JSON files used for testing (e.g., `fixtures/service_pod.rego`).

## Modularisation for Scalability

The modular structure allows easy expansion of the framework. For example:

- The **Service Pod module** is currently implemented with its own tests and mock data.
- Future modules (e.g. S3, RDS, IAM) can be added under the `modules` directory with minimal changes to the main framework.

This structure ensures that the policy remains organised and extensible.

## Safety Nets

To ensure the integrity of changes, the OPA Auto Approve Policy includes the following safeguards:

- **Always Fail if IAM Changes Are Involved**:
  - Changes to IAM policies or policy attachments will fail validation automatically.

- **No Unauthorised Kubernetes YAML Changes**:
  - Ensures no changes occur outside the Terraform configuration, particularly to Kubernetes YAML files.

- **Excludes Specific Resources**:
  - Validation ensures no changes occur to:
    - IAM policies
    - IAM policy attachments

## How to Test Locally

You need the [OPA CLI tool](https://www.openpolicyagent.org/docs/latest/cli/) for testing it locally.

You can install it with the below commmand:

```
brew install opa
```

Execute the following commands in the `opa-auto-approve-policy` directory:

1. **Manual Tests**:
   - Run OPA validation against mock Terraform plans:
     ```bash
     opa exec --decision terraform/analysis/allow --bundle . <tf-json-filepath> --log-level info --log-format json-pretty
     ```

2. **Unit Tests**:
   - Test the OPA policies using the built-in OPA testing framework:
     ```bash
     opa test . -v
     ```

3. **Format Code**:
   - Format OPA files using the `opa fmt` command:
     ```bash
     opa fmt . -w
     ```

## Next Steps

**Expanding Module Development**:

- The framework is designed for modularisation, with the `service_pod` module already implemented as a foundation.
- The next step will focus on developing additional modules for other resource types, such as S3, RDS, and IAM.
- Each new module will include resource-specific validation logic, tests, and fixtures to ensure seamless integration into the existing framework.
