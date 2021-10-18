package authenticate

import (
	"context"
	"errors"
	"fmt"
	"io/ioutil"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

// GitHubClient takes a GitHub personal access key as a string and builds
// and returns a GitHub client to the caller.
func GitHubClient(token string) (*github.Client, error) {
	if token == "" {
		return nil, errors.New("Personal access token is empty, unable to create GitHub client.")
	}

	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{
			AccessToken: token,
		},
	)
	tc := oauth2.NewClient(ctx, ts)

	return github.NewClient(tc), nil
}

// KubeConfigFromS3Bucket takes four arguments:
// bucket: The name of the s3 bucket to grab your kubeconfig file from.
// s3FileName: The name of the kubeconfig file in the bucket.
// clusterCtx: The cluster context name to use i.e. live.service.justice.gov.uk
// region: The AWS region of the bucket.
// It will return a Kubernetes clientset for use to query the cluster.
func KubeConfigFromS3Bucket(bucket, s3FileName, region string) error {
	buff := &aws.WriteAtBuffer{}
	session, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		return err
	}

	downloader := s3manager.NewDownloader(session)

	numBytes, err := downloader.Download(buff, &s3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(s3FileName),
	})

	if err != nil {
		return err
	}
	if numBytes < 1 {
		return fmt.Errorf("error the kubecfg file downloaded is empty and must have failed")
	}

	data := buff.Bytes()
	err = ioutil.WriteFile("~/.kube/config", data, 0644)
	if err != nil {
		return err
	}

	return nil
}

func KubeClientFromConfig(configFile, clusterCtx string) (clientset *kubernetes.Clientset, err error) {
	client, err := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
		&clientcmd.ClientConfigLoadingRules{ExplicitPath: configFile},
		&clientcmd.ConfigOverrides{
			CurrentContext: clusterCtx,
		}).ClientConfig()
	if err != nil {
		return nil, err
	}

	clientset, _ = kubernetes.NewForConfig(client)
	if err != nil {
		return nil, err
	}

	return
}
