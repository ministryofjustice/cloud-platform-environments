## Notes
- True/False or Score for auto approval?
- Safety Net:
    - Always fail if involved IAM changes
- Auto Approve for Service Pod:
    - Namespace for Service Pod == Namespace of deployment
    - Actual role of Service Pod == Role define by IRSA inside the Namespace
    - Auto approve only valid if only Servie Pod is in the change
    - Handle the creation/modification of multiple service pods
- Add tests