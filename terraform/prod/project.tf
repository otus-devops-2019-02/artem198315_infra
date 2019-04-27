resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "shinta:${file("${var.public_key_path}")}appuser:${file("${var.public_key_path}")}appuser2:${file("${var.public_key_path}")}"
}
