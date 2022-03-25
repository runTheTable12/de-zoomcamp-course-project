terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_cloud_folder_id
  zone      = "ru-central1-a"
}

// Use keys to create bucket
resource "yandex_storage_bucket" "tf-de-zoocamp-project-bucket" {
  access_key = var.yandex_cloud_access_key
  secret_key = var.yandex_cloud_secret_key
  bucket = "tf-de-zoocamp-project-bucket"
}

resource "yandex_mdb_postgresql_cluster" "de-project" {
  name        = "project-dwh"
  environment = "PRESTABLE"
  network_id  = var.yandex_cloud_network_id

  config {
    version = 12
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 16
    }
    postgresql_config = {
      max_connections                   = 395
      enable_parallel_hash              = true
      vacuum_cleanup_index_scale_factor = 0.2
      autovacuum_vacuum_scale_factor    = 0.34
      default_transaction_isolation     = "TRANSACTION_ISOLATION_READ_COMMITTED"
      shared_preload_libraries          = "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  database {
    name  = var.db_name
    owner = var.db_username
  }

  user {
    name       = var.db_username
    password   = var.db_password
    conn_limit = 50
    permission {
      database_name = var.db_name
    }
    settings = {
      default_transaction_isolation = "read committed"
      log_min_duration_statement    = 5000
    }
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.de-project.id
  }
}

resource "yandex_vpc_subnet" "de-project" {
  zone           = "ru-central1-a"
  network_id     = var.yandex_cloud_network_id
  v4_cidr_blocks = ["10.5.0.0/24"]
}