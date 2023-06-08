plugin "terraform" {
  enabled = true
  version = "0.3.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

plugin "aws" {
  enabled = true
  version = "0.23.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
