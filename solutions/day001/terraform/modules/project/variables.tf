variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "project_name" {
  description = "The display name of the project"
  type        = string
}

variable "folder_id" {
  description = "The folder ID to place the project in"
  type        = string
}

variable "billing_account_id" {
  description = "The billing account ID to associate with the project"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the project"
  type        = map(string)
  
  validation {
    condition     = contains(keys(var.labels), "environment") && contains(keys(var.labels), "team") && contains(keys(var.labels), "cost-center")
    error_message = "Labels must include 'environment', 'team', and 'cost-center'."
  }
}

variable "apis_to_enable" {
  description = "List of APIs to enable in the project"
  type        = list(string)
  default     = []
}

variable "auto_create_network" {
  description = "Whether to auto-create the default network"
  type        = bool
  default     = false
}
