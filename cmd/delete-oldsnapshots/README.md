# Generate Deprecated Ingress API for 1.22

This project deletes snapshots older than 1 year, in AWS account = "754256621582".

## How to run

To run the application locally, you must have the following:

- An variable set called `ownerId` with the value of your AWS Account ID.
- An variable set called `awsRegion` that contains the valid AWS region.
- An variable set called `daysOlder` to delete the snapshots older than given days.

Then you can run:

```bash
go run delete-oldsnapshots.go
```
