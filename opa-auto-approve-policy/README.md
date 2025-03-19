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

## Adding a new module

1. Create your new module directory and folder structure following the policy structure below
2. Plan your policy out carefully with pseudo code
3. Write your policy using the other modules for reference (be careful to not to be caught out by dynamic terraform module naming in the plan eg. `module.ecr` is not a good basis for selecting resources as the module name doesn't have to be "ecr" instead get a resource which is concrete in the module and work backwards to the `module.address`)
4. Generate a mock tf plan for testing (out a tf plan to json and pull out the relevant fields)
5. Ensure you have **complete** test coverage `opa test . -v` (use [print()](https://www.openpolicyagent.org/docs/latest/debugging/#using-the-print-built-in-function) to debug your values along the way)
6. Use your tfplan.json to test against the module with `opa exec --decision terraform/analysis/allow --bundle . <path-to-tf-plan>.json --log-level info --log-format json-pretty`
7. Once you're happy with your module, add the module to the `module_allowlist` module

## How It Works

### OPA Validation Against Terraform Plans Steps

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
├── service_pod/
│   ├── service_pod.rego
│   ├── main.rego
│   └── test/
│       ├── fixtures/
│       │   └── changes.rego
│       └── main_test.rego
├── module_allowlist/
└── ecr/
```

### Key Components

There is a dir for each module and then 2 additional modules: "module_allowlist/" and "iam".

Modules should pass if there is no terraform changed outside of the "module_allowlist". We need this extra module to make sure that PRs don't get approved when contain terraform for a module that isn't covered.

The "iam" module prevents us from auto approving prs with policy changes in.

1. **`<dir>/main.rego`**:

   - The primary entry point for the OPA policy, containing the overarching logic for auto-approval.

2. **`<dir>/<functionality>.rego`**:

   - These files contain the rego functionality/ logic needed in the `main.rego` file.
   - Example: `service_pod.rego` handles validation for service pods module deploymet.

3. **Tests and Fixtures**:
   - Each module includes:
     - **Test File**: Validates the module’s OPA logic (e.g., `service_pod_test.rego`).
     - **Fixtures**: Mock Terraform plan JSON files used for testing (e.g., `fixtures/service_pod.rego`).

## Modularisation for Scalability

The modular structure allows easy expansion of the framework. For example:

- The **Service Pod module** is currently implemented with its own tests and mock data.
- Future modules (e.g. S3, RDS, IAM) can be added in their own directory with zero changes to other modules.

This structure ensures that the policy remains organised and extensible.

## Safety Nets

To ensure the integrity of changes, the OPA Auto Approve Policy includes the following safeguards:

- **Always Fail if IAM Changes Are Involved**:

  - Changes to IAM policies or policy attachments will fail validation automatically.

- **No Unauthorised Kubernetes YAML Changes**:

  - Ensures no changes occur outside the Terraform configuration, particularly to Kubernetes YAML files.

- **Prevent smuggling changes into auto-approve with module_allowlist**
  - Make sure resources changed are resources that are on the allow list

## How to Test Locally

You need the [OPA CLI tool](https://www.openpolicyagent.org/docs/latest/cli/) for testing it locally.

You can install it with the below command:

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
