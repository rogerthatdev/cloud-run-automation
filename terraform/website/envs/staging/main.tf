# Staging environment

module "test_run_service" {
  source           = "../../modules/cloud-run-service"
  run_service_name = "website"
  primary_revision_image_url = "us-docker.pkg.dev/cloudrun/container/hello"
  primary_revision_traffic_percent = 100
  revision_b_name = "website-4b7172"
}