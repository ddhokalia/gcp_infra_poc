terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 4.0" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "utils_repo" {
  provider     = google
  location     = var.region
  repository_id = "genai-utils"
  format       = "PYTHON"
}

resource "google_storage_bucket" "function_source" {
  name     = "${var.project_id}-cf-source"
  location = var.region
}

resource "google_cloudfunctions_function" "cf_demo" {
  name        = "cf-demo-v2"
  runtime     = "python311"
  entry_point = "hello"
  region      = var.region

  source_archive_bucket = google_storage_bucket.function_source.name
  # assume uploaded zip artifact
  source_archive_object = "cf-demo-v2.zip"
  trigger_http          = true
  available_memory_mb   = 128
}
