terraform {
  required_version = ">= 1.2.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }

 # Dynamically include all Terraform files in the subfolder as sources
  dynamic "module" {
    for_each = fileset("./", "*.tf")

    content {
      source = "./${module.key}"
    }
  }
 

}