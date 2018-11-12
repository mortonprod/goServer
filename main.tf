provider "google" {
  credentials = "${file("account.json")}"
  project     = "terrafrom"
  region      = "europe-west2"
}
