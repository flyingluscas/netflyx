output "connector_access_token" {
  value     = twingate_connector_tokens.connector_tokens.access_token
  sensitive = true
}

output "connector_refresh_token" {
  value     = twingate_connector_tokens.connector_tokens.refresh_token
  sensitive = true
}

output "remote_network_id" {
  value = twingate_remote_network.network.id
}
