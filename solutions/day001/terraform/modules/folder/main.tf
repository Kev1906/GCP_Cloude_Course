resource "google_folder" "folder" {
  display_name = var.folder_name
  parent       = var.parent_folder_id != "" ? "folders/${var.parent_folder_id}" : "organizations/${var.organization_id}"
}
