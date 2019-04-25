output ext_ip_addr {
  value = "${google_compute_instance.reddit.*.network_interface.0.access_config.0.nat_ip}"
}

output reddit-instances {
  value = "${google_compute_instance.reddit.*.self_link}"
}
