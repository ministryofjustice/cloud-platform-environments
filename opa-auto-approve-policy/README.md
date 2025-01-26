## Notes

- ~~True/False or Score for auto approval?~~
- Safety Net:

  - ~~Always fail if involved IAM changes~~
  - Doesn't touch k8s yaml file - how to check? any git command to show no change in that layer? run `git diff -- cloud-platform-environments/namespaces/live.cloud-platform.service.justice.gov.uk/<namespace>` in concourse?
  - Doesn't touch:
    - ~~iam policies~~
    - ~~iam policy attachments~~

- Auto Approve for Service Pod:
  - ~~Namespace for Service Pod == Namespace of deployment~~
  - ~~Actual role of Service Pod == Role define by IRSA inside the Namespace~~
  - ~~Auto approve only valid if only Service Pod is in the change~~
  - ~~Handle the creation/modification of multiple service pods~~
  - ~~need to ensure "no-op" for module.irsa.kubernetes_service_account.generated_sa~~
- Add tests

```
opa exec --decision terraform/analysis/allow --bundle ./ tfplan-servicepod-only.json --log-level info --log-format json-pretty
```

```
opa fmt . -w
```

```
opa test . -v
```

### Next Steps

1. ~~figure out how to wildcard the module name~~
2. modularise
3. write tests
4. ~~check that the assigned service pod role is from IRSA (created in this namespace)~~
