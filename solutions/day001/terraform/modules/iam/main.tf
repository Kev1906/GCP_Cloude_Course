resource "google_project_iam_member" "members" {
  for_each = {
    for pair in flatten([
      for role, members in var.iam_bindings : [
        for member in members : {
          role   = role
          member = member
        }
      ]
    ]) : "${pair.role}-${pair.member}" => pair
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_project_iam_binding" "authoritative" {
  for_each = var.authoritative ? var.iam_bindings : {}

  project = var.project_id
  role    = each.key
  members = each.value
}
