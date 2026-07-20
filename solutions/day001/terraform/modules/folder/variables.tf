variable "organization_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account_id" {
  description = "GCP Billing Account ID"
  type        = string
}

variable "folder_name" {
  description = "Name of the folder to create"
  type        = string
}

variable "parent_folder_id" {
  description = "Parent folder ID (optional, defaults to organization)"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to the folder"
  type        = map(string)
  default     = {}
}
