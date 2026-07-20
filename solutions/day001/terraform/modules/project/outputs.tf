output "project_id" {
  description = "The ID of the created project"
  value       = google_project.project.project_id
}

output "project_number" {
  description = "The numeric ID of the created project"
  value       = google_project.project.number
}

output "project_name" {
  description = "The name of the created project"
  value       = google_project.project.name
}
