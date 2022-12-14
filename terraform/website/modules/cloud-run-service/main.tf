data "google_project" "app" {
}

locals {
  primary_revision_name = "${var.run_service_name}-${random_id.revision_suffix.hex}"
}

# Service accounts

resource "random_string" "service_account_suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "google_service_account" "runner" {
  account_id   = "clound-runner-${random_string.service_account_suffix.result}"
  display_name = "Cloud Run service runner"
}

resource "google_project_service_identity" "cloud_run_agent" {
  provider = google-beta
  project  = data.google_project.app.project_id
  service  = "run.googleapis.com"
}

resource "random_id" "revision_suffix" {
  keepers = {
    # Generate a new suffix everytime primary_revision_image_url is changed.
    primary_revision_image_url = var.primary_revision_image_url
  }
  byte_length = 3
}

resource "google_cloud_run_service" "my_app" {
  name     = var.run_service_name
  location = var.region
  template {
    spec {
      containers {
        image = var.primary_revision_image_url
      }
      service_account_name = google_service_account.runner.email
    }
    metadata {
      name = local.primary_revision_name
    }
  }
  # This is the primary revision
  traffic {
    percent       = var.primary_revision_traffic_percent
    revision_name = local.primary_revision_name # will always be newly created revision
  }

  traffic {
    percent       = 100 - var.primary_revision_traffic_percent
    revision_name = var.revision_b_name == "" ? local.primary_revision_name : var.revision_b_name # Defaults to the same as revision A if not provided.
  }

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.my_app.location
  project     = google_cloud_run_service.my_app.project
  service     = google_cloud_run_service.my_app.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

output "latest_revision" {
  value = "${google_cloud_run_service.my_app.status[0].latest_created_revision_name}"
}

# Can be used to check if this is the first time creating Run Service (id will be null if resource doesn't exist.)
# data "google_cloud_run_service" "run_service" {
#   project  = var.project_id
#   name     = var.run_service_name
#   location = var.region

#   depends_on = [
#     time_sleep.wait_60_seconds
#   ]
# }