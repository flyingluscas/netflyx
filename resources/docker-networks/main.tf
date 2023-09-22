resource "docker_network" "bridge" {
  name = var.bridge_network_name
}

resource "docker_network" "macvlan" {
  name   = var.macvlan_network_name
  driver = "macvlan"

  ipam_config {
    subnet  = "192.168.0.0/24"
    gateway = "192.168.0.1"
  }

  options = {
    parent = "enp1s0"
  }
}
