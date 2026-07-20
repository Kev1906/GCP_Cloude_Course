resource "google_project" "project" {
  project_id          = var.project_id
  name                = var.project_name
  folder_id           = var.folder_id
  billing_account     = var.billing_account_id
  labels              = var.labels
  auto_create_network = var.auto_create_network
}

resource "google_project_service" "apis" {
  for_each = toset(var.apis_to_enable)

  project = google_project.project.project_id
  service = each.value

  disable_on_destroy = false
}
