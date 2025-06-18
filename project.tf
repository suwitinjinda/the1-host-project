provider "google" {
  project = "the1-share-stg"
  region  = "asia-southeast1"
}

resource "google_project" "project" {
  name       = "the1-share-stg"
  project_id = "the1-share-stg-a1b1"
  org_id     = "84682267661"
  # folder_id  = "71613682013"
  billing_account = "01D996-3302C6-5F0E2F"
}

resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com"
  ])
  project = google_project.project.project_id
  service = each.value
}

resource "google_compute_shared_vpc_host_project" "host" {
  project = google_project.project.project_id

  depends_on = [
    google_project_service.services["compute.googleapis.com"]
  ]
}

resource "google_compute_network" "vpc" {
  name                    = "the1-vpc-net-share-stg"
  auto_create_subnetworks = false
  project                 = google_project.project.project_id
}

resource "google_compute_subnetwork" "gke_control" {
  name          = "the1-subnet-gke-control-stg"
  ip_cidr_range = "10.167.177.0/28"
  region        = "asia-southeast1"
  network       = google_compute_network.vpc.id
  project       = google_project.project.project_id
}

resource "google_compute_subnetwork" "gke_node" {
  name          = "the1-subnet-gke-node-stg"
  ip_cidr_range = "10.167.176.0/24"
  region        = "asia-southeast1"
  network       = google_compute_network.vpc.id
  project       = google_project.project.project_id

  secondary_ip_range {
    range_name    = "the1-subnet-gke-pod-stg"
    ip_cidr_range = "10.167.128.0/19"
  }

  secondary_ip_range {
    range_name    = "the1-subnet-gke-service-stg"
    ip_cidr_range = "10.167.160.0/20"
  }
}

##add service project
resource "google_compute_shared_vpc_service_project" "attach" {
  host_project    = "the1-share-stg-a1b1"
  service_project = "the1-gke-stg-463109"
}
