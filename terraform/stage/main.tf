terraform {
  required_version = "~> 0.11"
}

provider "google" {
  //credentials = "${file("account.json")}"
  project = "${var.project}"
  region  = "${var.region}"
}

module "fw" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}

module "app" {
  source           = "../modules/app"
  region           = "${var.region}"
  zone             = "${var.zone}"
  private_key_path = "${var.private_key_path}"
  disk_image       = "${var.disk_image}"
}

module "db" {
  source        = "../modules/db"
  zone          = "${var.zone}"
  db_disk_image = "${var.db_disk_image}"
}
