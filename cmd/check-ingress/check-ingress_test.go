package main

import (
	"testing"
)

func Test_checkAnnotation(t *testing.T) {
	goodHost := "https://reports.cloud-platform.service.justice.gov.uk/ingress_weighting"
	badHost := "obviouslyFakeName"

	type args struct {
		host *string
	}

	tests := []struct {
		name string
		args args
		// want    *IngressReport
		wantErr bool
	}{
		{
			name: "GET valid json data",
			args: args{
				host: &goodHost,
			},
			wantErr: false,
		},
		{
			name: "GET invalid json data",
			args: args{
				host: &badHost,
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := checkAnnotation(tt.args.host)
			if (err != nil) != tt.wantErr {
				t.Errorf("checkAnnotation() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
		})
	}
}
