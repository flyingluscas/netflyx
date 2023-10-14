resource "twingate_resource" "resource" {
  name                        = var.name
  address                     = var.address
  alias                       = var.alias
  remote_network_id           = var.remote_network_id
  is_visible                  = var.web
  is_browser_shortcut_enabled = var.web
  is_authoritative            = true

  access {
    group_ids = var.admin_only ? [var.admin_group_id] : [var.public_group_id, var.admin_group_id]
  }

  dynamic "protocols" {
    for_each = var.web == true ? toset([1]) : toset([])

    content {
      allow_icmp = false

      tcp {
        policy = "RESTRICTED"
        ports  = var.web_ports
      }

      udp {
        policy = "DENY_ALL"
      }
    }
  }

  dynamic "protocols" {
    for_each = var.ssh == true ? toset([1]) : toset([])

    content {
      allow_icmp = false

      tcp {
        policy = "RESTRICTED"
        ports  = ["22"]
      }

      udp {
        policy = "DENY_ALL"
      }
    }
  }
}
