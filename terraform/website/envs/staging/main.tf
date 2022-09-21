# Staging environment

module "test_run_service" {
  source           = "../../modules/cloud-run-service"
  run_service_name = "website"
  # primary_revision_image_url = ""
  # primary_revision_traffic_percent = 100
  # revision_b_name = ""
}