variable "eks_cluster_name" {
  description = "The name of the EKS cluster (auto-supplied by the cloud-platform-environments pipeline)"
}

variable "namespace" {
  description = "The Kubernetes namespace"
  default     = "vscode-marketplace"
}

variable "github_owner" {
  description = "GitHub organisation"
  default     = "ministryofjustice"
}

variable "github_repository" {
  description = "GitHub repository name for this project"
  default     = "vscode-marketplace"
}

# --- Standard Cloud Platform resource tags

variable "business_unit" {
  description = "Area of the MoJ responsible for the service"
  default     = "Justice Digital"
}

variable "application" {
  description = "Application name"
  default     = "VS Code Private Marketplace"
}

variable "is_production" {
  description = "Whether this namespace is production"
  default     = "true"
}

variable "team_name" {
  description = "The team responsible for this service"
  default     = "vscode-marketplace-admins"
}

variable "environment_name" {
  description = "Environment name"
  default     = "production"
}

variable "infrastructure_support" {
  description = "Team contact for infrastructure support (team-name (team-email))"
  default     = "Dean Longstaff (dean.longstaff@justice.gov.uk)"
}
