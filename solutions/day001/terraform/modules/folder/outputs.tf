output "folder_id" {
  description = "The ID of the created folder"
  value       = google_folder.folder.name
}

output "folder_name" {
  description = "The name of the created folder"
  value       = google_folder.folder.display_name
}
