resource "google_storage_bucket" "dr-historical-data-sys" {
  name     = "dr-historical-data-sys"
  location = "us-east1"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket" "dr-microstrategy-2" {
  name     = "dr-microstrategy-2"
  location = "us-east1"
  storage_class  = "REGIONAL"
}