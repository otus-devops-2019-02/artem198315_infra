variable region {
  type = "string"
}

variable zone {
  type = "string"
}

variable disk_image {
  type = "string"
}

variable private_key_path {
  type = "string"
}

variable reddit_count {
  type    = "string"
  default = "1"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app"
}
