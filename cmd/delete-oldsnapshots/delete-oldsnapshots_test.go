package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/ec2/ec2iface"
	"testing"
	"time"
)

// Mocked EC2 client and methods.
type mockedEC2 struct {
	ec2iface.EC2API
	DescribeSnapshotsOutput ec2.DescribeSnapshotsOutput
}

func (m *mockedEC2) DescribeSnapshots(*ec2.DescribeSnapshotsInput) (*ec2.DescribeSnapshotsOutput, error) {
	return &m.DescribeSnapshotsOutput, nil
}

// Test for deleteOldSnapshots func
func Test_deleteOldSnapshots(t *testing.T) {

	currentTime := time.Now()

	describeSnapshotsDeleted := ec2.DescribeSnapshotsOutput{
		Snapshots: []*ec2.Snapshot{
			{
				SnapshotId: aws.String("sp-12345678"),
				StartTime:  &currentTime,
			},
		},
	}
	// Define test case as a struct.
	cases := []struct {
		Name     string
		Resp     ec2.DescribeSnapshotsOutput
		Expected error
	}{
		{
			Name:     "DeleteSnapshots",
			Resp:     describeSnapshotsDeleted,
			Expected: nil,
		},
	}

	// Iterate through the test case defined above
	for _, c := range cases {

		// Create a sub-test for each case
		t.Run(c.Name, func(t *testing.T) {

			// Run the test using the mocked EC2 client and specified return value
			snapshots := deleteOldSnapshots(
				&mockedEC2{DescribeSnapshotsOutput: c.Resp}, 1)

			// Test that the returned string matches what we expect
			if snapshots != c.Expected {
				t.Errorf("got %q, want %q", snapshots, c.Expected)
			}
		})
	}
}
