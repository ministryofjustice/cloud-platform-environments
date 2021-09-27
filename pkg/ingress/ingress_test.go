package ingress

import (
	"testing"
)

func TestCheckAnnotation(t *testing.T) {
	type args struct {
		endPoint string
	}
	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		{
			name: "Fetch all annotations",
			args: args{
				endPoint: "ingress_weighting",
			},
			wantErr: false,
		},
		{
			name: "Fail to check annotations",
			args: args{
				endPoint: "%",
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := CheckAnnotation(tt.args.endPoint)
			if (err != nil) != tt.wantErr {
				t.Errorf("CheckAnnotation() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
		})
	}
}
