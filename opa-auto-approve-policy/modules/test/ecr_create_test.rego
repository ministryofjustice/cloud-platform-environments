# package test.terraform.analysis

# import data.terraform.analysis

# test_allow_if_namespace_matches if {
#     result := analysis.is_ecr_create_valid with input as ecr_create_mock_tfplan
#     result == true
# }