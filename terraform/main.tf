provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_member" "allUsers" {
  location        = var.region
  project         = var.project_id
  service         = google_cloud_run_service.default.name
  role            = "roles/run.invoker"
  member          = "allUsers"
}

output "cloud_run_url" {
  value = google_cloud_run_service.default.status[0].url
}

