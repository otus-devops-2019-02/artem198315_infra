resource "google_compute_address" "reddit_ip" {
  name = "ext-ip"
}

resource "google_compute_instance" "reddit" {
  count        = "${var.reddit_count}"
  name         = "reddit-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  tags = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.reddit_ip.address}"
    }
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file("${var.private_key_path}")}"
  }

  #provisioner "file" {
  #  source      = "files/puma.service"
  #  destination = "/tmp/puma.service"
  #}

  #provisioner "remote-exec" {
  #  script = "files/deploy.sh"
  #}
}

resource "google_compute_firewall" "firewall-puma" {
  name        = "allow-puma"
  description = "firewall rule for access to reddit app"
  priority    = "1000"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292","80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}



