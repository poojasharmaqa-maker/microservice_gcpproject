resource "google_composer_environment" "cloud_composer_env" {
  provider = "google-beta"
  name = "dr-systest-composer-env"
  region = "us-east1"

  config {
      node_count = 3

    node_config {
      zone = "us-east1-b"
      machine_type = "n1-highmem-2"
      network = "projects/mva-sys/global/networks/vdc-systest"
      subnetwork =  "projects/mva-sys/regions/us-east1/subnetworks/systest-app"
    }
  
    software_config {
      python_version= "3"
      pypi_packages = {
        pandas = ""
        pandas_gbq = ""
        pymysql = ""
      }
    }
    
  }
}