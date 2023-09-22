output "bridge_network_id" {
  value = docker_network.bridge.id
}

output "macvlan_network_id" {
  value = docker_network.macvlan.id
}
