terraform {
  backend "gcs" {
    bucket = "storage-bucket-artem198315-stage"
    prefix = "terraform/stage"
  }
}
