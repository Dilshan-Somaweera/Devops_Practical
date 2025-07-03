provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_container_cluster" "primary" {
  name               = "wordpress-cluster"
  location           = var.zone
  initial_node_count = 1
  deletion_protection = false

  node_config {
    machine_type = "e2-small"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  ip_allocation_policy {  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = google_container_cluster.primary.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

resource "google_compute_firewall" "wordpress_http" {
  name    = "wordpress-http-access"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  #target_tags   = ["gke-wordpress-cluster-default-pool"]
  
  description = "Allow HTTP access to WordPress"
}

/*
resource "null_resource" "apply_k8s" {
  provisioner "local-exec" {
    command = <<EOT
      gcloud container clusters get-credentials wordpress-cluster --zone ${var.zone} --project ${var.project_id}
      kubectl apply -f ./k8s/mysql-secret.yaml
      kubectl apply -f ./k8s/mysql-deployment.yaml
      kubectl apply -f ./k8s/mysql-service.yaml
      kubectl apply -f ./k8s/wordpress-deployment.yaml
      kubectl apply -f ./k8s/wordpress-service.yaml
      kubectl apply -f ./k8s/network-policy.yaml
    EOT
  }

  depends_on = [google_container_cluster.primary]
}
*/