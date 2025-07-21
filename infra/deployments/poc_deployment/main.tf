variable "region" {
  type = string
}

provider "google" {
  project = "slw-patenthub-dev"
  region  = var.region
}

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../cf_demo"
  output_path = "${path.module}/function-source.zip"
}

resource "google_storage_bucket_object" "cf_source" {
  name   = "cf-demo-v2-source.zip"
  bucket = "your-upload-bucket-name"
  source = data.archive_file.function_zip.output_path
}

resource "google_cloudfunctions_function" "cf_demo" {
  name        = "cf-demo-v2"
  description = "Demo Cloud Function"
  runtime     = "python311"
  region      = var.region
  source_archive_bucket = google_storage_bucket_object.cf_source.bucket
  source_archive_object = google_storage_bucket_object.cf_source.name
  entry_point = "hello_world"
  trigger_http = true
  available_memory_mb = 256
  environment_variables = {
    PYTHONHTTPSVERIFY = "0"
  }
}
