package ingress

import (
	"context"

	networkingv1 "k8s.io/api/networking/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

// GetAllIngresses takes a Kubernetes clientset and returns all ingress with type *v1.IngressList and an error.
func GetAllIngressesFromCluster(clientset *kubernetes.Clientset) (*networkingv1.IngressList, error) {
	ingressList, err := clientset.NetworkingV1().Ingresses("").List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		return nil, err
	}
	return ingressList, nil
}

// IngressWithClass gets IngressClassName looping over all ingress objects and set the IngressClass if present,
// if not present, set as undefined
func IngressWithClass(ingressList *networkingv1.IngressList) ([]map[string]string, error) {
	s := make([]map[string]string, 0)

	for _, i := range ingressList.Items {
		m := make(map[string]string)
		m["name"] = i.Name
		m["namespace"] = i.Namespace
		if i.Spec.IngressClassName != nil {
			m["ingressClass"] = *i.Spec.IngressClassName
		} else {
			m["ingressClass"] = "undefined"
		}
		s = append(s, m)

	}
	return s, nil
}
