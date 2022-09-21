locals {
  services = [
    "run.googleapis.com",
  ]
}

resource "google_project_service" "default" {
  for_each                   = toset(local.services)
  service                    = each.value
  disable_dependent_services = true
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [
    google_project_service.default
  ]

  create_duration = "60s"
}