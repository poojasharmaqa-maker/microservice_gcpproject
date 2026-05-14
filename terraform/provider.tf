provider "google" {
  project = "artful-affinity-219719"
  region  = "us-central1"
  zone    = "us-central1-c"
  credentials = "${file("../DR/dr-bq-pubsub.json")}"
}

