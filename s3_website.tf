resource "random_id" "s3_suffix" {


  byte_length = 4
}
locals {
  computed_bucket_name = "${var.prefix}.${var.domain_name}.${random_id.s3_suffix.hex}"
}

resource "aws_s3_bucket" "websitebucket" {
  bucket = local.computed_bucket_name

  tags = local.common_tags
}

resource "aws_s3_bucket_cors_configuration" "cors_config" {
  bucket = aws_s3_bucket.websitebucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["POST",
      "GET",
      "PUT",
      "DELETE",
    "HEAD"]
    allowed_origins = ["*"]
    #allowed_origins = ["https://${var.prefix}.${var.domain_name}"]
    max_age_seconds = 3000
  }
}


