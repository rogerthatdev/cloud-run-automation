# Staging environment

module "test_run_service" {
  source                           = "../../modules/cloud-run-service"
  run_service_name                 = var.run_service_name
  primary_revision_image_url       = var.primary_revision_image_url
  primary_revision_traffic_percent = var.primary_revision_traffic_percent
  revision_b_name                  = var.revision_b_name
}
