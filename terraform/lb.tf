resource "google_compute_target_pool" "reddit-pool" {
  name = "reddit-pool"

  instances = [
     "${google_compute_instance.reddit.*.self_link}"
  ]

  health_checks = [
    "${google_compute_http_health_check.reddit-hc.name}"
  ]
}

resource "google_compute_http_health_check" "reddit-hc" {
  name               = "reddit"
  request_path       = "/"
  port = 9292
  check_interval_sec = 5
  timeout_sec        = 1
}

resource "google_compute_forwarding_rule" "reddit-ft" {
  name       = "reddit"
  target     = "${google_compute_target_pool.reddit-pool.self_link}"
  port_range = "9292"
  network_tier =  "STANDARD"
}




