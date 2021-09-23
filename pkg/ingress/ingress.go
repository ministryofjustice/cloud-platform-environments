package ingress

import (
	"encoding/json"

	"github.com/ministryofjustice/cloud-platform-how-out-of-date-are-we/reports/pkg/hoodaw"
)

// IngressReport allows us to unmarshal the json from the Hoodaw page into
// a data type.
type IngressReport struct {
	WeightingIngress []struct {
		Namespace string
		Resource  string
	} `json:"weighting_ingress"`
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
