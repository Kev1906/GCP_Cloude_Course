terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "datamartx-terraform-state"
    prefix = "day001/foundation"
  }
}

provider "google" {
  region = "us-central1"
}
