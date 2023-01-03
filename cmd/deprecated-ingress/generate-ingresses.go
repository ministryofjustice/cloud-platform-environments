package main

import (
	"encoding/csv"
	"encoding/json"
	"flag"
	"fmt"
	"log"

	"os"
	"os/exec"

	"github.com/doitintl/kube-no-trouble/pkg/judge"
	"github.com/ministryofjustice/cloud-platform-environments/pkg/authenticate"
	"github.com/ministryofjustice/cloud-platform-environments/pkg/ingress"
	"github.com/ministryofjustice/cloud-platform-environments/pkg/namespace"
	v1 "k8s.io/api/core/v1"
	_ "k8s.io/client-go/plugin/pkg/client/auth/oidc"
)

var (
	ctx        = flag.String("context", "arn:aws:eks:eu-west-2:754256621582:cluster/live", "Kubernetes context specified in kubeconfig")
	kubeconfig = flag.String("kubeconfig", os.Getenv("KUBECONFIG"), "Name of kubeconfig file")
	region     = flag.String("region", os.Getenv("AWS_REGION"), "AWS Region")
)

func main() {
	flag.Parse()

	if *ctx == "" || *kubeconfig == "" || *region == "" {
		log.Fatalln("You need to specify a non-empty value for context, kubeconfig and aws region.")
	}

	// Gain access to a Kubernetes cluster using a config file for given cluster context.
	clientset, err := authenticate.CreateClientFromConfigFile(*kubeconfig, *ctx)
	if err != nil {
		log.Fatalln(err.Error())
	}

	// run kubent to find deprecated apis
	deprecatedListJson, err := executeKubent(*kubeconfig, *ctx)
	if err != nil {
		log.Fatalln("error in executing kubent", err)
	}

	// Get the list of namespaces from the cluster which is set in the clientset
	namespaces, err := namespace.GetAllNamespacesFromCluster(clientset)
	if err != nil {
		log.Fatalln(err.Error())
	}
	// Get all ingress resources from the cluster which is set in the clientset
	ingressList, err := ingress.GetAllIngressesFromCluster(clientset)
	if err != nil {
		log.Fatalln(err.Error())
	}

	// Get IngressClassName from all ingresses
	ingressClassList, err := ingress.IngressWithClass(ingressList)
	if err != nil {
		log.Fatalln(err.Error())
	}

	// Build the CSV file merging deprecated API and namespace details per ingress
	err = buildCSV(ingressClassList, deprecatedListJson, namespaces)
	if err != nil {
		log.Fatalln(err.Error())
	}

}

// executeKubent executes kubent command agains the context set
func executeKubent(kubeconfig string, context string) ([]judge.Result, error) {
	output, err := exec.Command("kubent", "-k", kubeconfig, "-x", context, "-ojson").Output()
	if err != nil {
		return nil, err
	}

	// encoding into JSON format
	var results []judge.Result
	err = json.Unmarshal([]byte(output), &results)
	if err != nil {
		return nil, err
	}
	return results, nil
}

// buildCSV creates the CSV file merging deprecated API and namespace details per ingress
func buildCSV(ingressClassList []map[string]string, deprecatedList []judge.Result, namespaces []v1.Namespace) error {
	w := csv.NewWriter(os.Stdout)
	// get required details of each namespace and store it in namespace map
	for _, i := range ingressClassList {
		ingressName := i["name"]
		namespace := i["namespace"]
		ingressClass := i["ingressClass"]
		apiVersion := checkApiVersion(ingressName, namespace, deprecatedList)
		// Add to csv only if API version is deprecated or IngressClass is not defined
		if apiVersion != "networking.k8s.io/v1" || (ingressClass != "default" && ingressClass != "modsec") {
			slack := getSlackChannelFromNamespace(namespace, namespaces)

			err := w.Write([]string{fmt.Sprintf("%v", ingressName), fmt.Sprintf("%v", namespace), fmt.Sprintf("%v", apiVersion), fmt.Sprintf("%v", ingressClass), fmt.Sprintf("%v", slack)})
			if err != nil {
				return err
			}
		}
	}
	w.Flush()
	return nil
}

// checkApiVersion get the ingress name and check if that ingress is in the deprecated list
// If present, return the deprecated api version else return the non deprecated one
func checkApiVersion(ingressName string, namespace string, deprecatedList []judge.Result) string {
	apiVersion := ""
	for _, r := range deprecatedList {
		if r.Kind == "Ingress" && r.Name == ingressName && r.Namespace == namespace {
			apiVersion = r.ApiVersion
			return apiVersion
		}
	}
	return "networking.k8s.io/v1"
}

// getSlackChannelFromNamespace get the namespace name and a list of namespaces, loop over the list
// and return the slackChannel of given namespace
func getSlackChannelFromNamespace(namespace string, namespaces []v1.Namespace) string {
	for _, ns := range namespaces {
		if ns.Name == namespace {
			return ns.Annotations["cloud-platform.justice.gov.uk/slack-channel"]
		}
	}
	return ""
}
