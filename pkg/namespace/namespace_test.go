package namespace

import (
	"reflect"
	"testing"
)

func TestChangedInPR(t *testing.T) {
	type args struct {
		branchRef string
		token     string
		repo      string
		owner     string
	}
	tests := []struct {
		name    string
		args    args
		want    []string
		wantErr bool
	}{
		{
			name: "Fail with empty token",
			args: args{
				branchRef: "/refs/pull/5501/merge",
				token:     "",
				repo:      "cloud-platform-environments",
				owner:     "ministryofjustice",
			},
			wantErr: true,
			want:    nil,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := ChangedInPR(tt.args.branchRef, tt.args.token, tt.args.repo, tt.args.owner)
			if (err != nil) != tt.wantErr {
				t.Errorf("ChangedInPR() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("ChangedInPR() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestNamespace_SetRbacTeam(t *testing.T) {
	type fields struct {
		Application      string
		BusinessUnit     string
		DeploymentType   string
		Cluster          string
		DomainNames      []string
		GithubURL        string
		Name             string
		RbacTeam         []string
		TeamName         string
		TeamSlackChannel string
	}
	type args struct {
		cluster string
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		wantErr bool
	}{
		{
			name: "Find correct namespace",
			fields: fields{
				Name: "abundant-namespace-dev",
			},
			args: args{
				cluster: "live-1",
			},
			wantErr: false,
		},
		{
			name: "Find fake namespace",
			fields: fields{
				Name: "FAKE-NAMESPACE",
			},
			args: args{
				cluster: "live-1",
			},
			wantErr: true,
		},
		{
			name: "Use fake cluster name",
			fields: fields{
				Name: "abundant-namespace-dev",
			},
			args: args{
				cluster: "FAKE-CLUSTER",
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ns := &Namespace{
				Application:      tt.fields.Application,
				BusinessUnit:     tt.fields.BusinessUnit,
				DeploymentType:   tt.fields.DeploymentType,
				Cluster:          tt.fields.Cluster,
				DomainNames:      tt.fields.DomainNames,
				GithubURL:        tt.fields.GithubURL,
				Name:             tt.fields.Name,
				RbacTeam:         tt.fields.RbacTeam,
				TeamName:         tt.fields.TeamName,
				TeamSlackChannel: tt.fields.TeamSlackChannel,
			}
			if err := ns.SetRbacTeam(tt.args.cluster); (err != nil) != tt.wantErr {
				t.Errorf("Namespace.SetRbacTeam() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestGetNamespace(t *testing.T) {
	type args struct {
		s string
		h string
	}
	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		{
			name: "Get real namespace",
			args: args{
				s: "abundant-namespace-dev",
				h: "hosted_services",
			},
			wantErr: false,
		},
		{
			name: "Get FAKE namespace",
			args: args{
				s: "FAKE_NAMESPACE",
				h: "hosted_services",
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := GetNamespace(tt.args.s, tt.args.h)
			if (err != nil) != tt.wantErr {
				t.Errorf("GetNamespace() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
		})
	}
}

func TestGetAllNamespacesFromHoodaw(t *testing.T) {
	type args struct {
		endPoint string
	}
	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		{
			name: "Successfully get all namespaces",
			args: args{
				endPoint: "hosted_services",
			},
			wantErr: false,
		},
		{
			name: "Fail to get all namespaces",
			args: args{
				endPoint: "%",
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := GetAllNamespacesFromHoodaw(tt.args.endPoint)
			if (err != nil) != tt.wantErr {
				t.Errorf("GetAllNamespaces() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
		})
	}
}

func TestGetProductionNamespaces(t *testing.T) {
	type args struct {
		ns AllNamespaces
	}
	tests := []struct {
		name           string
		args           args
		wantNamespaces []string
		wantErr        bool
	}{
		{
			name: "Expect to return correct slice of namespaces",
			args: args{
				ns: AllNamespaces{
					Namespaces: []Namespace{
						{
							Name:           "namespace-dev",
							DeploymentType: "dev",
						},
						{
							Name:           "namespace-prod",
							DeploymentType: "prod",
						},
						{
							Name:           "namespace-live",
							DeploymentType: "live-ns",
						},
						{
							Name:           "namespace-production",
							DeploymentType: "PRoDucTion",
						},
					},
				},
			},
			wantNamespaces: []string{"namespace-prod", "namespace-live", "namespace-production"},
			wantErr:        false,
		},
		{
			name: "Pass empty list of namespaces",
			args: args{
				ns: AllNamespaces{
					Namespaces: []Namespace{},
				},
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gotNamespaces, err := GetProductionNamespaces(tt.args.ns)
			if (err != nil) != tt.wantErr {
				t.Errorf("GetProductionNamespaces() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(gotNamespaces, tt.wantNamespaces) {
				t.Errorf("GetProductionNamespaces() = %v, want %v", gotNamespaces, tt.wantNamespaces)
			}
		})
	}
}

func TestGetNonProductionNamespaces(t *testing.T) {
	type args struct {
		ns AllNamespaces
	}
	tests := []struct {
		name           string
		args           args
		wantNamespaces []string
		wantErr        bool
	}{
		{
			name: "Expect to return correct slice of namespaces",
			args: args{
				ns: AllNamespaces{
					Namespaces: []Namespace{
						{
							Name:           "namespace-dev",
							DeploymentType: "dev",
						},
						{
							Name:           "namespace-prod",
							DeploymentType: "prod",
						},
						{
							Name:           "namespace-test",
							DeploymentType: "test",
						},
						{
							Name:           "namespace-somethingelse",
							DeploymentType: "RANdoMChAr",
						},
					},
				},
			},
			wantNamespaces: []string{"namespace-dev", "namespace-test", "namespace-somethingelse"},
			wantErr:        false,
		},
		{
			name: "Pass empty list of namespaces",
			args: args{
				ns: AllNamespaces{
					Namespaces: []Namespace{},
				},
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gotNamespaces, err := GetNonProductionNamespaces(tt.args.ns)
			if (err != nil) != tt.wantErr {
				t.Errorf("GetNonProductionNamespaces() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(gotNamespaces, tt.wantNamespaces) {
				t.Errorf("GetNonProductionNamespaces() = %v, want %v", gotNamespaces, tt.wantNamespaces)
			}
		})
	}
}
