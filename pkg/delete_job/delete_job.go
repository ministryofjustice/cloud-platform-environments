package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"path/filepath"

	batchv1 "k8s.io/api/batch/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

func main() {
	var (
		kubeconfig *string
		dryRun     bool
	)

	flag.BoolVar(&dryRun, "dry-run", false, "If true, only display the jobs that would be deleted")
	if home := homedir.HomeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}
	flag.Parse()

	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
	if err != nil {
		fmt.Printf("Error building kubeconfig: %v\n", err)
		os.Exit(1)
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		fmt.Printf("Error creating Kubernetes client: %v\n", err)
		os.Exit(1)
	}

	namespaces, err := clientset.CoreV1().Namespaces().List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		fmt.Printf("Error listing namespaces: %v\n", err)
		os.Exit(1)
	}

	for _, ns := range namespaces.Items {
		namespace := ns.Name
		fmt.Printf("Processing namespace: %s\n", namespace)

		// List Jobs in the namespace
		jobList, err := clientset.BatchV1().Jobs(namespace).List(context.TODO(), metav1.ListOptions{})
		if err != nil {
			fmt.Printf("Error listing jobs in namespace %s: %v\n", namespace, err)
			continue
		}

		for _, job := range jobList.Items {
			// Check if the job is completed and exclude those have ttlSecondsAfterFinished or is owned by a CronJob
			if isJobCompleted(&job) && !hasTTLSecondsAfterFinished(&job) && !isOwnedByCronJob(&job) {
				if dryRun {
					fmt.Printf("[Dry Run] Would delete job '%s' in namespace '%s'\n", job.Name, namespace)
				} else {
					fmt.Printf("Deleting job '%s' in namespace '%s'\n", job.Name, namespace)
					// Delete the job
					deletePolicy := metav1.DeletePropagationForeground
					err := clientset.BatchV1().Jobs(namespace).Delete(context.TODO(), job.Name, metav1.DeleteOptions{
						PropagationPolicy: &deletePolicy,
					})
					if err != nil {
						fmt.Printf("Error deleting job '%s' in namespace '%s': %v\n", job.Name, namespace, err)
					}
				}
			}
		}
	}

	fmt.Println("Completed job deletion process.")
}

// Check if the job has completed successfully
func isJobCompleted(job *batchv1.Job) bool {
	for _, c := range job.Status.Conditions {
		if c.Type == batchv1.JobComplete && c.Status == "True" {
			return true
		}
	}
	return false
}

// Check if the job has ttlSecondsAfterFinished set
func hasTTLSecondsAfterFinished(job *batchv1.Job) bool {
	return job.Spec.TTLSecondsAfterFinished != nil
}

// Check if the job is owned by a CronJob
func isOwnedByCronJob(job *batchv1.Job) bool {
	for _, owner := range job.OwnerReferences {
		if owner.Kind == "CronJob" {
			return true
		}
	}
	return false
}
