variable "twingate_api_key" {
  type      = string
  sensitive = true
}

variable "twingate_network_name" {
  type = string
}

variable "data_dir_path" {
  type = string
}

variable "plex_claim_token" {
  type      = string
  sensitive = true
}

variable "nginx_conf_folder" {
  type = string
}

variable "twingate_public_group_id" {
  type = string
}

variable "twingate_admin_user_id" {
  type = string
}
