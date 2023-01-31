package main

import (
	"flag"
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/ec2/ec2iface"
)

var (
	awsRegion = flag.String("aws-region", "eu-west-2", "AWS_REGION")
	ownerId   = flag.String("owner-id", "754256621582", "OWNER_ID")
	daysOld   = flag.Int("days-old", 400, "DAYS_OLD")
)

// Delete snapshots older than given days
func deleteOldSnapshots(svc ec2iface.EC2API, days int) error {
	output, err := svc.DescribeSnapshots(&ec2.DescribeSnapshotsInput{Filters: []*ec2.Filter{
		{
			Name: aws.String("owner-id"),
			Values: []*string{
				aws.String(*ownerId),
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
	fmt.Printf("\nSnapshots deleted older than '%v' days", *daysOld)
	return nil
}

func main() {
	// Create AWS API Session
	awsSession, err := session.NewSession(&aws.Config{
		Region: aws.String(*awsRegion),
	})
	if err != nil {
		log.Fatal("Error creating AWS session:", err.Error())
	}
	// Instantiate new EC2 client
	svc := ec2.New(awsSession)

	flag.Parse()
	// Delete snapshots older than given no of days
	err = deleteOldSnapshots(svc, *daysOld)
	if err != nil {
		log.Fatal("Error deleting old snapshots:", err.Error())
	}
}
