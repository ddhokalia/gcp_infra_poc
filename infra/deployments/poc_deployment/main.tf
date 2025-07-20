terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1) Create GCS bucket for function code
resource "google_storage_bucket" "function_source_bucket" {
  name     = "${var.project_id}-gcp-poc-function-source"
  location = var.region
  uniform_bucket_level_access = true
}

# 2) Zip your function code
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../apis/v2/cf-demo"
  output_path = "${path.module}/cf-demo.zip"
}

# 3) Upload the zip to GCS
resource "google_storage_bucket_object" "function_zip_object" {
  name   = "cf-demo-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_source_bucket.name
  source = data.archive_file.function_zip.output_path
}

# 4) Deploy the Cloud Function
resource "google_cloudfunctions_function" "cf_demo" {
  name                    = "cf-demo-v2"
  runtime                 = "python311"
  entry_point             = "hello"
  region                  = var.region
  source_archive_bucket   = google_storage_bucket.function_source_bucket.name
  source_archive_object   = google_storage_bucket_object.function_zip_object.name
  trigger_http            = true
  available_memory_mb     = 128
}

# 5) Allow public (unauthenticated) access
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.cf_demo.project
  region         = google_cloudfunctions_function.cf_demo.region
  cloud_function = google_cloudfunctions_function.cf_demo.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
