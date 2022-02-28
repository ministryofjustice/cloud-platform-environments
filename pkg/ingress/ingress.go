package ingress

import (
	"context"
	"encoding/json"

	"github.com/ministryofjustice/cloud-platform-how-out-of-date-are-we/reports/pkg/hoodaw"
	"k8s.io/api/networking/v1beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

// IngressReport allows us to unmarshal the json from the Hoodaw page into
// a data type.
type IngressReport struct {
	WeightingIngress []struct {
		Namespace string
		Resource  string
	} `json:"weighting_ingress"`
}

// GetAllIngresses takes a Kubernetes clientset and returns all ingress with type *v1beta1.IngressList and an error.
func GetAllIngressesFromCluster(clientset *kubernetes.Clientset) (*v1beta1.IngressList, error) {
	ingressList, err := clientset.NetworkingV1beta1().Ingresses("").List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		return nil, err
	}
	return ingressList, nil
}

// CheckAnnotation takes a http endpoint and generates an IngressReport
// data type. IngressReport contains a collection of namespaces that contain
// an ingress resource that don't have the required annoation.
func CheckAnnotation(endPoint string) (*IngressReport, error) {
	body, err := hoodaw.QueryApi(endPoint)
	if err != nil {
		return nil, err
	}

	namespaces := &IngressReport{}

	err = json.Unmarshal(body, &namespaces)
	if err != nil {
		return nil, err
	}

	return namespaces, nil
}
