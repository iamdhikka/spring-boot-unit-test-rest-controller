variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region for Cloud Run deployment"
  type        = string
  default     = "asia-southeast2"
}

variable "service_name" {
  description = "Cloud Run Service Name"
  type        = string
}

variable "image" {
  description = "Docker image to deploy on Cloud Run"
  type        = string
}
