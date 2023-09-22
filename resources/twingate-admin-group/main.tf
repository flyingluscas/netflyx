data "twingate_user" "admin_user" {
  id = var.admin_user_id
}

resource "twingate_group" "admin" {
  name             = "Admin"
  is_authoritative = false
  user_ids         = [data.twingate_user.admin_user.id]
}
