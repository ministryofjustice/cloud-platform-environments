package main

import (
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
)

var awsRegion string = "eu-west-2"
var ownerId string = "754256621582"

func deleteOldSnapshots(svc *ec2.EC2, days int) {
	output, err := svc.DescribeSnapshots(&ec2.DescribeSnapshotsInput{Filters: []*ec2.Filter{
		{
			Name: aws.String("owner-id"),
			Values: []*string{
				aws.String(ownerId),
			},
		},
	}})
	if err != nil {
		log.Fatal(err)
	}
	time := time.Now().AddDate(0, 0, -1*days)
	for _, snapshot := range output.Snapshots {
		if snapshot.StartTime.Before(time) {
			svc.DeleteSnapshot(&ec2.DeleteSnapshotInput{SnapshotId: snapshot.SnapshotId})
			fmt.Println(*snapshot.SnapshotId, "deleted")
		}
	}
	fmt.Printf("\nNo snapshots to delete older than '%v' days", days)
}

func main() {
	awsSession, err := session.NewSession(&aws.Config{
		Region: aws.String(awsRegion),
	})
	if err != nil {
		log.Fatal(err)
	}
	svc := ec2.New(awsSession)
	deleteOldSnapshots(svc, 420)
}
