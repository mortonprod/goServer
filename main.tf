terraform {
  backend "s3" {
    bucket = "personal-projects-terraform-state"
    key    = "goServer"
    region = "us-east-1"
  }
}

provider "google" {
  credentials = "${file("cred.json")}"
  project     = "${var.projectName}"
  region      = "${var.region}"
}

provider "aws" {
  region      = "${var.awsRegion}"
}

data "aws_region" "current" {
}


resource "aws_lambda_function" "goServer" {
  function_name    = "goServer"
  filename         = "goServer.zip"
  handler          = "goServer"
  source_code_hash = "${base64sha256(file("goServer.zip"))}"
  role             = "${aws_iam_role.goServer.arn}"
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 1
}

resource "aws_iam_role" "goServer" {
  name               = "goServer"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow"
  }
}
POLICY
}

resource "aws_lambda_permission" "goServer" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.goServer.arn}"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_resource" "goServer" {
  rest_api_id = "${aws_api_gateway_rest_api.goServer.id}"
  parent_id   = "${aws_api_gateway_rest_api.goServer.root_resource_id}"
  path_part   = "goServer"
}

resource "aws_api_gateway_rest_api" "goServer" {
  name = "goServer"
}

#           GET
# Internet -----> API Gateway
resource "aws_api_gateway_method" "goServer" {
  rest_api_id   = "${aws_api_gateway_rest_api.goServer.id}"
  resource_id   = "${aws_api_gateway_resource.goServer.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "goServer" {
  rest_api_id             = "${aws_api_gateway_rest_api.goServer.id}"
  resource_id             = "${aws_api_gateway_resource.goServer.id}"
  http_method             = "${aws_api_gateway_method.goServer.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.goServer.arn}/invocations"
}

# This resource defines the URL of the API Gateway.
resource "aws_api_gateway_deployment" "goServer_v1" {
  depends_on = [
    "aws_api_gateway_integration.goServer"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.goServer.id}"
  stage_name  = "v1"
}

# Set the generated URL as an output. Run `terraform output url` to get this.
output "url" {
  value = "${aws_api_gateway_deployment.goServer_v1.invoke_url}${aws_api_gateway_resource.goServer.path}"
}

data "aws_acm_certificate" "goServer" {
  domain   = "${var.domain}"
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "goServer" {
  domain_name = "${var.subDomain}.${var.domain}"
  certificate_arn = "${data.aws_acm_certificate.goServer.arn}"
}

resource "aws_route53_zone" "main" {
  name = "${var.domain}"
}


resource "aws_route53_record" "goServer" {
  zone_id = "${aws_route53_zone.main.id}" 

  name = "${aws_api_gateway_domain_name.goServer.domain_name}"
  type = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.goServer.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.goServer.cloudfront_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_api_gateway_base_path_mapping" "goServer" {
  api_id      = "${aws_api_gateway_rest_api.goServer.id}"
  stage_name  = "${aws_api_gateway_deployment.goServer_v1.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.goServer.domain_name}"
}
























#-------------------------
# Google cloud resources
#-------------------------

# resource "google_storage_bucket" "bucket" {
#   name = "${var.projectName}-goserver"
#   force_destroy = true
# }

# resource "google_storage_bucket_object" "object" {
#   name   = "dist"
#   bucket = "${google_storage_bucket.bucket.name}"
#   source = "./dist/main"
#   }

# resource "google_cloudfunctions_function" "function" {
#   name                  = "${var.projectName}-function"
#   description           = "The go function for ${var.projectName}"
#   available_memory_mb   = 128
#   source_archive_bucket = "${google_storage_bucket.bucket.name}"
#   source_archive_object = "${google_storage_bucket_object.object.name}"
#   trigger_http          = true
#   timeout               = 60
#   entry_point           = "HelloWorld"
#   labels {
#     my-label = "my-label-value"
#   # }
#   environment_variables {
#     MY_ENV_VAR = "my-env-var-value"
#   }
# }


# resource "google_compute_instance" "small" {
#   name         = "${var.computeName}"
#   machine_type = "f1-micro"
#   zone         = "${var.region}-b"

#   boot_disk {
#     initialize_params {
#       image = "ubuntu-1604-lts"
#     }
#   }

#   network_interface {
#     network       = "default"
#     access_config = {}
#   }
# }
