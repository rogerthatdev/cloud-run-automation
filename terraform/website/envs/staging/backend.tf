terraform {
  backend "gcs" {
    bucket = "cloud-run-auto-shared-c8b7-tf-states"
    prefix = "website/staging"
  }
}