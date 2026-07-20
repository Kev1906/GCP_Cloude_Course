# =============================================================================
# Folder IDs
# =============================================================================

output "folder_shared_services_id" {
  description = "Shared Services folder ID"
  value       = module.folder_shared_services.folder_id
}

output "folder_production_id" {
  description = "Production folder ID"
  value       = module.folder_production.folder_id
}

output "folder_staging_id" {
  description = "Staging folder ID"
  value       = module.folder_staging.folder_id
}

output "folder_development_id" {
  description = "Development folder ID"
  value       = module.folder_development.folder_id
}

output "folder_prod_marketplace_id" {
  description = "Production Marketplace folder ID"
  value       = module.folder_prod_marketplace.folder_id
}

output "folder_prod_logistics_id" {
  description = "Production Logistics folder ID"
  value       = module.folder_prod_logistics.folder_id
}

output "folder_prod_payments_id" {
  description = "Production Payments folder ID"
  value       = module.folder_prod_payments.folder_id
}

output "folder_prod_analytics_id" {
  description = "Production Analytics folder ID"
  value       = module.folder_prod_analytics.folder_id
}

output "folder_prod_corporate_id" {
  description = "Production Corporate folder ID"
  value       = module.folder_prod_corporate.folder_id
}

# =============================================================================
# Project IDs
# =============================================================================

output "project_networking_shared_id" {
  description = "Networking shared project ID"
  value       = module.project_networking_shared.project_id
}

output "project_security_shared_id" {
  description = "Security shared project ID"
  value       = module.project_security_shared.project_id
}

output "project_logging_shared_id" {
  description = "Logging shared project ID"
  value       = module.project_logging_shared.project_id
}

output "project_marketplace_prod_us_id" {
  description = "Marketplace Production US project ID"
  value       = module.project_marketplace_prod_us.project_id
}

output "project_marketplace_prod_eu_id" {
  description = "Marketplace Production EU project ID"
  value       = module.project_marketplace_prod_eu.project_id
}

output "project_logistics_prod_id" {
  description = "Logistics Production project ID"
  value       = module.project_logistics_prod.project_id
}

output "project_payments_prod_id" {
  description = "Payments Production project ID"
  value       = module.project_payments_prod.project_id
}

output "project_analytics_prod_id" {
  description = "Analytics Production project ID"
  value       = module.project_analytics_prod.project_id
}

output "project_corporate_prod_id" {
  description = "Corporate Production project ID"
  value       = module.project_corporate_prod.project_id
}

output "project_shared_dev_id" {
  description = "Shared Development project ID"
  value       = module.project_shared_dev.project_id
}

# =============================================================================
# Summary
# =============================================================================

output "summary" {
  description = "Summary of created resources"
  value = {
    folders  = 9
    projects = 15
    total_monthly_budget = "$180K"
  }
}
