# Shared environment (where ops module will be deployed)
data "google_project" "shared" {
}

resource "google_artifact_registry_repository" "web" {
  location      = "us-central1"
  repository_id = "web"
  description   = "Docker repository for web images"
  format        = "DOCKER"

  depends_on = [
    google_project_service.default
  ]
}

resource "google_artifact_registry_repository_iam_member" "cloud_builder_writer" {
  repository = google_artifact_registry_repository.web.name
  location   = google_artifact_registry_repository.web.location
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.cloud_builder.email}"
}

resource "google_pubsub_topic" "gcr" {
  name     = "gcr"
}

resource "google_service_account" "shared_terraformer" {
  account_id   = "shared-terraformer"
  display_name = "Terraform service account."
}

resource "google_service_account" "cloud_builder" {
  account_id   = "cloud-builder"
  display_name = "Service account for running cloud builds triggers"
}

# This is a trigger that looks at a yaml in the repo
resource "google_cloudbuild_trigger" "web_new_build" {
  name            = "website-new-build"
  description     = "This trigger will automatically build an new image based on merges to main in web directory on repo"
  service_account = google_service_account.cloud_builder.id
  filename        = "web/cloudbuild.yaml"
  included_files = [
    "web/*"
  ]
  github {
    owner = var.repo_owner
    name  = var.repo_name
    push {
      branch = "^main$"
    }
  }
  ignored_files = []
  substitutions = {
    _IMAGE      = "web"
    _REPOSITORY = "web"
    _LOCATION   = "us-central1"
  }
  tags = []
}

# resource "google_cloudbuild_trigger" "web_deploy_trigger" {
#   name            = "test-web-deploy-trigger"
#   description     = "*Testing - should automatically run terraform to update run service"
#   service_account = google_service_account.cloud_builder.id
#   # filename        = "terraform/website/envs/staging/cloudbuild.yaml"

#   git_file_source {
#     path      = "terraform/website/envs/staging/cloudbuild.yaml"
#     repo_type = "GITHUB"
#     revision  = "refs/heads/master"
#     uri       = "https://github.com/rogerthatdev/cloud-run-automation"
#   }
#   pubsub_config {
#     topic = "projects/cloud-run-auto-shared-c8b7/topics/gcr"
#   }

#   source_to_build {
#     ref       = "refs/heads/master"
#     repo_type = "GITHUB"
#     uri       = "https://github.com/rogerthatdev/cloud-run-automation"
#   }
#   ignored_files = []
#   substitutions = {

#   }
#   tags = []
# }

resource "google_storage_bucket" "build_logs" {
  name          = "${data.google_project.shared.project_id}-build-logs"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.build_logs.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.cloud_builder.email}"
}

output "ar_repo_urls" {
  value = {
    "web" = "${google_artifact_registry_repository.web.location}-docker.pkg.dev/${google_artifact_registry_repository.web.project}/${google_artifact_registry_repository.web.name}"
  }
}


resource "google_cloudbuild_trigger" "web_deploy_trigger" {
  name            = "test-web-deploy-trigger"
  description     = "*Testing - should automatically run terraform to update run service"
  service_account = google_service_account.cloud_builder.id
  github {
         owner = var.repo_owner
         name  = var.repo_name

         push {
          branch       = "main"
          invert_regex = false
         }
  }
  build {
    logs_bucket = google_storage_bucket.build_logs.name
    step {
      id        = "tf init"
      name       = "hashicorp/terraform:1.0.0"
      dir = "$_TF_DIRECTORY"
      entrypoint = "sh"
      args = ["-c",
        <<-EOT
        terraform init
        EOT
      ]

    }
    step {
      id        = "tf plan"
      name       = "hashicorp/terraform:1.0.0"
      dir = "$_TF_DIRECTORY"
      entrypoint = "sh"
      args = ["-c",
        <<-EOT
        terraform plan
        EOT
      ]

    }
    options {
      logging = "GCS_ONLY"
    }
  }

  substitutions = {
    "_TF_DIRECTORY" = "terraform/website/envs/staging"
  }
  
}