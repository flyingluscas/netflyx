variable "name" {
  type = string
}

variable "container_name" {
  type    = string
  default = null
}

variable "data_dir_path" {
  type = string
}

variable "config_dir_path" {
  type    = string
  default = null
}

variable "docker_bridge_network_id" {
  type = string
}
