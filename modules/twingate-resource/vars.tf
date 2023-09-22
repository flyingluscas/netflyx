variable "name" {
  type = string
}

variable "address" {
  type = string
}

variable "alias" {
  type    = string
  default = null
}

variable "remote_network_id" {
  type = string
}

variable "public_group_id" {
  type = string
}

variable "admin_group_id" {
  type = string
}

variable "admin_only" {
  type = bool
}

variable "web" {
  type = bool
}

variable "ssh" {
  type = bool
}
