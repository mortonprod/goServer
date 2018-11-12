provider "google" {
  credentials = "${file("cred.json")}"
  project     = "terrafrom"
  region      = "europe-west2"
}
