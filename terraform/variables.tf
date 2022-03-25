variable "db_name" {
  description = "Project database name"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_token" {
  description = "yandex cloud token"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_id" {
  description = "yandex cloud id"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_folder_id" {
  description = "yandex cloud folder id"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_access_key" {
  description = "yandex cloud access key"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_secret_key" {
  description = "yandex cloud secret key"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_network_id" {
  description = "yandex cloud network id"
  type        = string
  sensitive   = true
}

