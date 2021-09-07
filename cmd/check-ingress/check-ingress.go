package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

type IngressReport struct {
	WeightingIngress []struct {
		Namespace string
	} `json:"weighting_ingress"`
}

var (
	nsToCompare = flag.String("namespace", "", "The namespace name of the service to check.")
	host        = flag.String("host", "https://reports.cloud-platform.service.justice.gov.uk/ingress_weighting", "hostname of hoodaw.")
)

func main() {
	flag.Parse()

	// Grab all namespaces that don't have the required annotation.
	namespaces, err := checkAnnotation(host)
	if err != nil {
		log.Fatalln("Error checking hoodaw:", err)
	}

	// If the namespace passed as an argument is found in our datatype, fail.
	for _, ingress := range namespaces.WeightingIngress {
		if ingress.Namespace == *nsToCompare {
			log.Println("Found: This namespace doesn't have the correct annotation.")
		}
	}
}

// checkAnnotation takes a http endpoint and generates an IngressReport
// data type. IngressReport contains a collection of namespaces that contain
// an ingress resource that don't have the required annoation.
func checkAnnotation(host *string) (*IngressReport, error) {
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
