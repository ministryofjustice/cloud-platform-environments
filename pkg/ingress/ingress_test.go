package ingress

import (
	"reflect"
	"testing"

	"k8s.io/api/networking/v1beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestIngressWithClass(t *testing.T) {
	ingressClass := "default"
	type args struct {
		ingressList *v1beta1.IngressList
	}
	tests := []struct {
		name    string
		args    args
		want    []map[string]string
		wantErr bool
	}{
		{
			name: "Get ingressClass default",
			args: args{
				ingressList: &v1beta1.IngressList{
					Items: []v1beta1.Ingress{
						{
							ObjectMeta: metav1.ObjectMeta{
								Namespace: "namespace-1",
								Name:      "ingress-1",
							},
							Spec: v1beta1.IngressSpec{
								IngressClassName: &ingressClass,
							},
						},
					},
				},
			},
			want: []map[string]string{
				{
					"name":         "ingress-1",
					"namespace":    "namespace-1",
					"ingressClass": "default",
				},
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := IngressWithClass(tt.args.ingressList)
			if (err != nil) != tt.wantErr {
				t.Errorf("IngressWithClass() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("IngressWithClass() = %v, want %v", got, tt.want)
			}
		})
	}
}
