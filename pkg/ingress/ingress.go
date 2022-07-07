package ingress

import (
	"context"

	"k8s.io/api/networking/v1beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

// GetAllIngresses takes a Kubernetes clientset and returns all ingress with type *v1beta1.IngressList and an error.
func GetAllIngressesFromCluster(clientset *kubernetes.Clientset) (*v1beta1.IngressList, error) {
	ingressList, err := clientset.NetworkingV1beta1().Ingresses("").List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		return nil, err
	}
	return ingressList, nil
}
