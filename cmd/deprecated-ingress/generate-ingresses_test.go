package main

import (
	"testing"

	"github.com/doitintl/kube-no-trouble/pkg/judge"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	_ "k8s.io/client-go/plugin/pkg/client/auth/oidc"
)

func Test_checkApiVersion(t *testing.T) {
	var testVersion1, _ = judge.NewVersion("1.19.0")
	type args struct {
		ingressName    string
		deprecatedList []judge.Result
	}
	tests := []struct {
		name string
		args args
		want string
	}{
		{
			name: "apiversion v1beta1",
			args: args{
				ingressName: "ingress-1",
				deprecatedList: []judge.Result{
					{
						Name:        "ingress-1",
						Namespace:   "ns-1",
						Kind:        "Ingress",
						ApiVersion:  "networking.k8s.io/v1beta1",
						RuleSet:     "Deprecated APIs removed in 1.22",
						ReplaceWith: "networking.k8s.io/v1beta1",
						Since:       testVersion1,
					},
				},
			},
			want: "networking.k8s.io/v1beta1",
		},
		{
			name: "apiversion v1",
			args: args{
				ingressName: "ingress-2",
				deprecatedList: []judge.Result{
					{
						Name:        "ingress-1",
						Namespace:   "ns-1",
						Kind:        "Ingress",
						ApiVersion:  "networking.k8s.io/v1",
						RuleSet:     "Deprecated APIs removed in 1.22",
						ReplaceWith: "networking.k8s.io/v1beta1",
						Since:       testVersion1,
					},
				},
			},
			want: "networking.k8s.io/v1",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := checkApiVersion(tt.args.ingressName, tt.args.deprecatedList); got != tt.want {
				t.Errorf("checkApiVersion() = %v, want %v", got, tt.want)
			}
		})
	}
}

func Test_buildCSV(t *testing.T) {
	type args struct {
		ingressClassList []map[string]string
		deprecatedList   []judge.Result
		namespaces       []v1.Namespace
	}
	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if err := buildCSV(tt.args.ingressClassList, tt.args.deprecatedList, tt.args.namespaces); (err != nil) != tt.wantErr {
				t.Errorf("buildCSV() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestgetSlackChannelFromNamespace(t *testing.T) {
	type args struct {
		namespace  string
		namespaces []v1.Namespace
	}
	tests := []struct {
		name string
		args args
		want string
	}{
		{
			name: "Get cloud-platform slack channel",
			args: args{
				namespace: "cloud-platform-dev",
				namespaces: []v1.Namespace{{
					ObjectMeta: metav1.ObjectMeta{
						Name: "cloud-platform-dev",
						Labels: map[string]string{
							"cloud-platform.justice.gov.uk/environment-name": "test",
							"cloud-platform.justice.gov.uk/is-production":    "false",
						},
						Annotations: map[string]string{
							"cloud-platform.justice.gov.uk/application":   "test-app",
							"cloud-platform.justice.gov.uk/business-unit": "test-bu",
							"cloud-platform.justice.gov.uk/owner:Digital": "Test Services: test@digital.justice.gov.uk",
							"cloud-platform.justice.gov.uk/slack-channel": "cloud-platform",
							"cloud-platform.justice.gov.uk/source-code":   "https://github.com/ministryofjustice/testrepo.git",
							"cloud-platform.justice.gov.uk/team-name":     "test-team",
						},
					},
				}},
			},
			want: "cloud-platform",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := getSlackChannelFromNamespace(tt.args.namespace, tt.args.namespaces); got != tt.want {
				t.Errorf("getSlackChannelFromNamespace() = %v, want %v", got, tt.want)
			}
		})
	}
}
