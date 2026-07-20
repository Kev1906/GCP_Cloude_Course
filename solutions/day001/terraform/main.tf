# =============================================================================
# Top-Level Folders
# =============================================================================

module "folder_shared_services" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Shared Services"
}

module "folder_production" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Production"
}

module "folder_staging" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Staging"
}

module "folder_development" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Development"
}

# =============================================================================
# Production Sub-Folders (by Line of Business)
# =============================================================================

module "folder_prod_marketplace" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Marketplace"
  parent_folder_id = replace(module.folder_production.folder_id, "folders/", "")
}

module "folder_prod_logistics" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Logistics"
  parent_folder_id = replace(module.folder_production.folder_id, "folders/", "")
}

module "folder_prod_payments" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Payments"
  parent_folder_id = replace(module.folder_production.folder_id, "folders/", "")
}

module "folder_prod_analytics" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Analytics"
  parent_folder_id = replace(module.folder_production.folder_id, "folders/", "")
}

module "folder_prod_corporate" {
  source = "./modules/folder"

  organization_id = var.organization_id
  folder_name     = "Corporate"
  parent_folder_id = replace(module.folder_production.folder_id, "folders/", "")
}

# =============================================================================
# Shared Services Projects
# =============================================================================

module "project_networking_shared" {
  source = "./modules/project"

  project_id         = "networking-shared"
  project_name       = "Networking Shared Services"
  folder_id          = module.folder_shared_services.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "platform"
    cost-center = "cc-9000"
    region      = "global"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

module "project_security_shared" {
  source = "./modules/project"

  project_id         = "security-shared"
  project_name       = "Security Shared Services"
  folder_id          = module.folder_shared_services.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "security"
    cost-center = "cc-9001"
    region      = "global"
  }

  apis_to_enable = [
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "securitycenter.googleapis.com"
  ]
}

module "project_logging_shared" {
  source = "./modules/project"

  project_id         = "logging-shared"
  project_name       = "Logging Shared Services"
  folder_id          = module.folder_shared_services.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "platform"
    cost-center = "cc-9000"
    region      = "global"
  }

  apis_to_enable = [
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

# =============================================================================
# Production Projects - Marketplace
# =============================================================================

module "project_marketplace_prod_us" {
  source = "./modules/project"

  project_id         = "marketplace-prod-us"
  project_name       = "Marketplace Production US"
  folder_id          = module.folder_prod_marketplace.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "marketplace"
    cost-center = "cc-1001"
    region      = "us"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com"
  ]
}

module "project_marketplace_prod_eu" {
  source = "./modules/project"

  project_id         = "marketplace-prod-eu"
  project_name       = "Marketplace Production EU"
  folder_id          = module.folder_prod_marketplace.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "marketplace"
    cost-center = "cc-1001"
    region      = "eu"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com"
  ]
}

# =============================================================================
# Production Projects - Logistics
# =============================================================================

module "project_logistics_prod" {
  source = "./modules/project"

  project_id         = "logistics-prod"
  project_name       = "Logistics Production"
  folder_id          = module.folder_prod_logistics.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "logistics"
    cost-center = "cc-1002"
    region      = "us"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "dataflow.googleapis.com"
  ]
}

# =============================================================================
# Production Projects - Payments (PCI Scope)
# =============================================================================

module "project_payments_prod" {
  source = "./modules/project"

  project_id         = "payments-prod"
  project_name       = "Payments Production"
  folder_id          = module.folder_prod_payments.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "payments"
    cost-center = "cc-1003"
    region      = "us"
    pci-scope   = "true"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}

# =============================================================================
# Production Projects - Analytics
# =============================================================================

module "project_analytics_prod" {
  source = "./modules/project"

  project_id         = "analytics-prod"
  project_name       = "Analytics Production"
  folder_id          = module.folder_prod_analytics.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "analytics"
    cost-center = "cc-1004"
    region      = "us"
  }

  apis_to_enable = [
    "bigquery.googleapis.com",
    "dataflow.googleapis.com",
    "composer.googleapis.com",
    "storage.googleapis.com"
  ]
}

# =============================================================================
# Production Projects - Corporate
# =============================================================================

module "project_corporate_prod" {
  source = "./modules/project"

  project_id         = "corporate-prod"
  project_name       = "Corporate Production"
  folder_id          = module.folder_prod_corporate.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "production"
    team        = "corporate"
    cost-center = "cc-1005"
    region      = "us"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "workspace.googleapis.com"
  ]
}

# =============================================================================
# Staging Projects
# =============================================================================

module "project_marketplace_staging" {
  source = "./modules/project"

  project_id         = "marketplace-staging"
  project_name       = "Marketplace Staging"
  folder_id          = module.folder_staging.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "staging"
    team        = "marketplace"
    cost-center = "cc-1001"
    region      = "us"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com"
  ]
}

module "project_logistics_staging" {
  source = "./modules/project"

  project_id         = "logistics-staging"
  project_name       = "Logistics Staging"
  folder_id          = module.folder_staging.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "staging"
    team        = "logistics"
    cost-center = "cc-1002"
    region      = "us"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com"
  ]
}

module "project_payments_staging" {
  source = "./modules/project"

  project_id         = "payments-staging"
  project_name       = "Payments Staging"
  folder_id          = module.folder_staging.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "staging"
    team        = "payments"
    cost-center = "cc-1003"
    region      = "us"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudkms.googleapis.com"
  ]
}

module "project_analytics_staging" {
  source = "./modules/project"

  project_id         = "analytics-staging"
  project_name       = "Analytics Staging"
  folder_id          = module.folder_staging.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "staging"
    team        = "analytics"
    cost-center = "cc-1004"
    region      = "us"
  }

  apis_to_enable = [
    "bigquery.googleapis.com",
    "dataflow.googleapis.com"
  ]
}

module "project_corporate_staging" {
  source = "./modules/project"

  project_id         = "corporate-staging"
  project_name       = "Corporate Staging"
  folder_id          = module.folder_staging.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "staging"
    team        = "corporate"
    cost-center = "cc-1005"
    region      = "us"
  }

  apis_to_enable = [
    "compute.googleapis.com"
  ]
}

# =============================================================================
# Development Projects
# =============================================================================

module "project_shared_dev" {
  source = "./modules/project"

  project_id         = "shared-dev"
  project_name       = "Shared Development"
  folder_id          = module.folder_development.folder_id
  billing_account_id = var.billing_account_id
  
  labels = {
    environment = "development"
    team        = "shared"
    cost-center = "cc-9999"
    region      = "us"
  }

  apis_to_enable = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com"
  ]
}
