package main

import (
	"testing"
	"time"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/ec2/ec2iface"

)

// Mocked EC2 client and methods. Each method is setup to return a pointer to the relevant struct attribute.
// This allows different return values to be set for each individual instantiation of the mocked client.
type mockedEC2 struct {
    ec2iface.EC2API
    DescribeSnapshotsOutput   ec2.DescribeSnapshotsOutput
}


func (m *mockedEC2) DescribeSnapshots(*ec2.DescribeSnapshotsInput) (*ec2.DescribeSnapshotsOutput, error) {
    return &m.DescribeSnapshotsOutput, nil
}

// var (
// 	// DescribeVpcsOutput - Single CIDR Block
// 	describeSnapshotsDeleted = ec2.DescribeSnapshotsOutput{
// 		Snapshots: []*ec2.Snapshot {
// 			{
// 				SnapshotId: aws.String("sp-0e3533b1b004a32f1"),
// 			},
// 		},
// 	}

// )


// Unit test for ListVpcCidrBlocks func
func TestDeleteOldSnapshots(t *testing.T) {

	timet := time.Now()

	describeSnapshotsDeleted := ec2.DescribeSnapshotsOutput{
		Snapshots: []*ec2.Snapshot {
			{
				SnapshotId: aws.String("sp-0e3533b1b004a32f1"),
				StartTime: &timet,
			},
		},
	}
	// Define each test case as a struct.
	// There are two specific cases tested for here:
	//
	// 1. A VPC with a single CIDR block attached
	// 2. A VPC with multiple CIDR blocks attached
	cases := []struct {
		Name     string
		Resp     ec2.DescribeSnapshotsOutput
		Expected error
	}{
		{
			Name:     "SingleCidrAssociation",
			Resp:     describeSnapshotsDeleted,
			Expected: nil,
		},
	}

	// Iterate through the list of test cases defined above
	for _, c := range cases {

		// Create a sub-test for each case
		t.Run(c.Name, func(t *testing.T) {

			// Run the test using the mocked EC2 client and specified return value
			ss := DeleteOldSnapshots(
				&mockedEC2{DescribeSnapshotsOutput: c.Resp},1)

			// Test that the returned string matches what we expect
			// assert.Equal(t, c.Expected, ss)
			if ss != c.Expected {
				t.Errorf("got %q, want %q", ss, c.Expected)
			}

		})
	}
}