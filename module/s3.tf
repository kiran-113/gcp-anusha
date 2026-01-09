module "network_vpc" {
 # for_each = var.create_vpc ? 1 : 0
  source   = "terraform-google-modules/network/google//modules/vpc"
  version  = "8.1.0"
  # insert the 2 required variables here
  project_id              = var.project_id
  network_name            = var.network_name
  auto_create_subnetworks = false
  mtu                     = 1460

}

module "cloud-storage" {
  for_each = var.create_s3 ? toset(["cloud-storage"]) : toset([])
  source  = "terraform-google-modules/cloud-storage/google"
  version = "6.0.1"
  # insert the 2 required variables here
  project_id              = var.project_id
  names= var.names
  force_destroy = { for k in var.names : k => true }

}