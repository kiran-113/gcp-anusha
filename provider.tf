locals {
  terraform_service_account = "terraform-sa@dev-project-482704.iam.gserviceaccount.com"
}

provider "google" {
  project                     = var.project_id
  impersonate_service_account = local.terraform_service_account
  request_timeout             = "60s"
}


  # Uncomment and configure the backend when you're ready to use remote state
# provider "google" {
#   alias = "impersonation"
#   scopes = [
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/userinfo.email",
#   ]
# }

# data "google_service_account_access_token" "default" {
#   provider               = google.impersonation
#   target_service_account = local.terraform_service_account
#   scopes                 = ["userinfo-email", "cloud-platform"]
#   lifetime               = "1200s"
# }

# provider "google" {
#   project         = var.project_id
#   access_token    = data.google_service_account_access_token.default.access_token
#   request_timeout = "60s"
# }


terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.22.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
    backend "gcs" {
    bucket = "tetsu-65465154"
    prefix = "terraform/state"
    }

}