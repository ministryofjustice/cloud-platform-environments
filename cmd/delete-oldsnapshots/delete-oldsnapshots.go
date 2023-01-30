package main

import (
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/ec2/ec2iface"
)

var awsRegion string = "eu-west-2"
var ownerId string = "754256621582"

// Delete snapshots older than provided days
func DeleteOldSnapshots(svc ec2iface.EC2API, days int) error {
	output, err := svc.DescribeSnapshots(&ec2.DescribeSnapshotsInput{Filters: []*ec2.Filter{
		{
			Name: aws.String("owner-id"),
			Values: []*string{
				aws.String(ownerId),
			},
		},
	}})
	if err != nil {
		return err
	}
	time := time.Now().AddDate(0, 0, -1*days)
	for _, snapshot := range output.Snapshots {
		if snapshot.StartTime.Before(time) {
			svc.DeleteSnapshot(&ec2.DeleteSnapshotInput{SnapshotId: snapshot.SnapshotId})
			fmt.Println(*snapshot.SnapshotId, "deleted")
		}
	}
    return nil
}

func main() {
	// Create AWS API Session
	awsSession, err := session.NewSession(&aws.Config{
		Region: aws.String(awsRegion),
	})
	if err != nil {
		log.Fatal(err)
	}
	// Instantiate new EC2 client
	svc := ec2.New(awsSession)

	// Delete snapshots older than given no of days
	err = DeleteOldSnapshots(svc, 420)
	if err != nil {
		log.Fatal(err)
	}
}
