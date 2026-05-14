resource "google_composer_environment" "cloud_composer_private_env" {
  provider = "google-beta"
  name   = "dr-dev-composer-env-3"
  region = "us-central1"
  config {
    node_count = 3

    node_config {
      zone = "us-central1-a"
      disk_size_gb = "98"
      machine_type = "n1-highmem-2"
      network = "projects/artful-affinity-219719/global/networks/gpc-vdc-test"
      subnetwork =  "projects/artful-affinity-219719/regions/us-central1/subnetworks/gpc-vdc-test-s1"

      ip_allocation_policy {
        use_ip_aliases = "true"
        cluster_ipv4_cidr_block = ""
        services_ipv4_cidr_block = ""
      }
    }
    software_config {
      image_version = "composer-1.7.2-airflow-1.9.0"
      pypi_packages = {
        pandas = ""
        pandas_gbq = ""
        pymysql = ""
      }
      python_version = "3"
    }

    private_environment_config {
      enable_private_endpoint = "true"
    }

  }
}
