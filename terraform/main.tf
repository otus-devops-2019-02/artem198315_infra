terraform {
  required_version = "~> 0.11"
}

provider "google" {
  //credentials = "${file("account.json")}"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "shinta:${file("${var.public_key_path}")}appuser1:${file("${var.public_key_path}")}appuser2:${file("${var.public_key_path}")}"
}

resource "google_compute_instance" "reddit" {
  name         = "reddit"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  tags = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  connection {
    type        = "ssh"
    user        = "shinta"
    agent       = false
    private_key = "${file("${var.private_key_path}")}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall-puma" {
  name        = "allow-puma"
  description = "firewall rule for access to reddit app"
  priority    = "1000"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["reddit-app"]
}
