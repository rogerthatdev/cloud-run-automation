locals {
  services = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com"
  ]
}

resource "google_project_service" "default" {
  for_each                   = toset(local.services)
  service                    = each.value
  disable_dependent_services = true
}