# Shared environment (where ops module will be deployed)

resource "google_artifact_registry_repository" "web" {
  location      = "us-central1"
  repository_id = "web"
  description   = "Docker repository for web images"
  format        = "DOCKER"

  depends_on = [
    google_project_service.default
  ]
}

resource "google_service_account" "shared_terraformer" {
  account_id   = "shared-terraformer"
  display_name = "Terraform service account."
}


output "ar_repo_urls" {
    value = {
       "web" = "${google_artifact_registry_repository.web.location}-docker.pkg.dev/${google_artifact_registry_repository.web.project}/${google_artifact_registry_repository.web.name}"
    }
}
