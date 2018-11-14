variable "region" {
  type = "string"
  default = "europe-west1"
}
variable "awsRegion" {
  type = "string"
  default = "us-east-1"
}
variable "projectName" {
  type = "string"
  default = "terraform-222321"
}

variable "computeName" {
  type = "string"
  default = "goserversmall"
}
variable "bucketName" {
  type = "string"
  default = "goServer"
}

variable "domain" {
  type = "string"
  default = "alex-test-site.co.uk"
}

variable "subDomain" {
  type = "string"
  default = "goserver"
}