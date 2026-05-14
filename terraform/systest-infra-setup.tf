# Initialize variables 
variable "cloud_sql_tier" {
    type = string
    default = "D0"
}
variable "db_names" {
    type = list(string)
}
variable "topic_name" {
  type  = list(string)
  default = []
}
variable "sub_name" {
  type = list(string)
  default = []
}
variable "topic_count" {
  type = number
}

# Create GKE cluster
resource "google_container_cluster" "gke-cluster" {
  name               = "minerva-1-n"
  network            = "vdc-systest"
  location           = "us-east1-b"
  subnetwork	     = "systest-app"
  remove_default_node_pool = true
  initial_node_count = 1
}

# Add NodePool to the created GKE cluster
resource "google_container_node_pool" "extra-pool" {
  name               = "extra-node-pool"
  location           = "us-east1-b"
  cluster            = "${google_container_cluster.gke-cluster.name}"
  initial_node_count = 3
  node_config {
    machine_type = "n1-standard-2"
  }
  autoscaling {
    min_node_count = 3
    max_node_count = 20
  }
}

# Pubsub topics
resource "google_pubsub_topic" "topic_creation" {
  count = length(var.topic_name)
  name = "${element(var.topic_name, count.index)}"
}

# Pubsub subscriptions
resource "google_pubsub_subscription" "subscription_creation" {
  count = "${length(var.topic_name) == length(var.sub_name) ? length(var.sub_name):0}"
  name  = "${element(var.sub_name, count.index)}"
  topic = "${element(var.topic_name, count.index)}"

  ack_deadline_seconds = 300
  message_retention_duration = "1200s"
  retain_acked_messages = true

  expiration_policy {
    ttl = "300000.5s"
  }
}

# Cloud SQL 

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "master" {
  name = "master-instance-${random_id.db_name_suffix.hex}"
  region = "us-east1"
  settings {
    tier = "${var.cloud_sql_tier}"
  }
}

resource "google_sql_database" "databases" {
  count = "${length(var.db_names)}"
  name      = "${element(var.db_names, count.index)}"
  instance  = "${google_sql_database_instance.master.name}"
}

# BigQuery Setup

variable "dataset_names" {
    type = list(string)
}

resource "google_bigquery_dataset" "minerva-1" {
  count                       = "${length(var.dataset_names)}"
  dataset_id                  = "${element(var.dataset_names, count.index)}"
  location                    = "US"
  default_table_expiration_ms = 3600000
}
