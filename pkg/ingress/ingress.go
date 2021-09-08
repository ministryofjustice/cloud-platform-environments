package ingress

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

// IngressReport allows us to unmarshal the json from the Hoodaw page into
// a data type.
type IngressReport struct {
	WeightingIngress []struct {
		Namespace string
	} `json:"weighting_ingress"`
}

// CheckAnnotation takes a http endpoint and generates an IngressReport
// data type. IngressReport contains a collection of namespaces that contain
// an ingress resource that don't have the required annoation.
func CheckAnnotation(host *string) (*IngressReport, error) {
	client := &http.Client{
		Timeout: time.Second * 2,
	}

	req, err := http.NewRequest("GET", *host, nil)
	if err != nil {
		log.Fatalln(err)
	}

	req.Header.Add("User-Agent", "ingress-annotation-check")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}

	if resp.Body != nil {
		defer resp.Body.Close()
	}

	body, err := ioutil.ReadAll(resp.Body)
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
