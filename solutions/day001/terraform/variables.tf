variable "organization_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account_id" {
  description = "GCP Billing Account ID"
  type        = string
}

variable "domain" {
  description = "Google Workspace domain"
  type        = string
  default     = "datamartx.com"
}
