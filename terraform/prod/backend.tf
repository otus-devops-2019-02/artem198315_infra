terraform {
  backend "gcs" {
    bucket = "gs://storage-bucket-artem198315-prod"
    prefix = "terraform/prod"
  }
}
