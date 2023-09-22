variable "docker_bridge_network_id" {
  type = string
}

variable "docker_macvlan_network" {
  type = object({
    id   = string
    ipv4 = string
  })
  default = null
}

variable "container_name" {
  type = string
}

variable "nginx_conf_folder" {
  type = string
}

variable "proxies" {
  type = list(object({
    upstream = string
    path     = string
    host     = string
    port     = number
  }))
}

variable "twingate" {
  type = object({
    remote_network_id = string
    public_group_id   = string
    admin_group_id    = string
  })
  default = null
}
