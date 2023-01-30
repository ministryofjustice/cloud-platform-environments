package main

import (
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/ec2/ec2iface"

)

// Mocked EC2 client and methods. Each method is setup to return a pointer to the relevant struct attribute.
// This allows different return values to be set for each individual instantiation of the mocked client.
type mockEC2Client struct {
    ec2iface.EC2API
    resp   ec2.DescribeSnapshotsOutput
    // result []string
}

func (m *mockEC2Client) DescribeSnapshots(*ec2.DescribeSnapshotsInput) (*ec2.DescribeSnapshotsOutput, error) {
    return &m.resp, nil
}

func TestdeleteOldSnapshots(t *testing.T) {
    cases := []mockEC2Client{
        {
            resp: ec2.DescribeSnapshotsOutput{
                Snapshots: []*ec2.Snapshot{
                    {
                        SnapshotId: aws.String("sp-0e3533b1b004a32f1"),
                    },
                    {
                        SnapshotId: aws.String("sp-0e3533b1b004a32f2"),
                    },
                    {
                        SnapshotId: aws.String("sp-0e3533b1b004a32f3"),
                    },
                },
            },
        },
    }

    for _, c := range cases {
        deleteOldSnapshots{DescribeSnapshotsOutput: c.resp}

        assert.Nil(object)

    }
}
