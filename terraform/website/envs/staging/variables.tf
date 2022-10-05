variable "run_service_name" {
  type        = string
  description = "Name for the Run service."
}

variable "primary_revision_image_url" {
  type        = string
  description = "URL for Run service container build."
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "primary_revision_traffic_percent" {
  type        = number
  description = "Percentage value for primary Cloud Run revision. The previous revision will default to 100 minus this value."
  default     = 100
}

variable "revision_b_name" {
  type        = string
  description = "Name of revision B. Must be existing revision, otherwise module will default to revision a."
  default     = ""
}