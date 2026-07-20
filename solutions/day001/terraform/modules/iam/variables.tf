variable "project_id" {
  description = "The project ID to apply IAM bindings to"
  type        = string
}

variable "iam_bindings" {
  description = "Map of role to list of members"
  type        = map(list(string))
  default     = {}
  
  # Example:
  # iam_bindings = {
  #   "roles/viewer" = ["group:viewers@datamartx.com"]
  #   "roles/editor" = ["group:editors@datamartx.com"]
  # }
}

variable "authoritative" {
  description = "Whether to use authoritative (google_project_iam_binding) or additive (google_project_iam_member) bindings"
  type        = bool
  default     = false
}
