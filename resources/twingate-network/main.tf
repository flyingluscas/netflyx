resource "twingate_remote_network" "network" {
  name = var.remote_network_name
}

resource "twingate_connector" "connector" {
  name                   = var.remote_network_name
  status_updates_enabled = true
  remote_network_id      = twingate_remote_network.network.id
}

resource "twingate_connector_tokens" "connector_tokens" {
  connector_id = twingate_connector.connector.id
}
