provider "google" {
  credentials = "${file("cred.json")}"
  project     = "terraform-222321"
  region      = "${var.region}"
}

resource "google_compute_instance" "small" {
  name         = "${var.computeName}"
  machine_type = "f1-micro"
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-lts"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }
}
