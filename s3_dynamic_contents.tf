
locals {
  computed_dynamic_contents_bucket_name = "dynamiccontents.${var.domain_name}.${random_id.s3_suffix.hex}"
}
resource "aws_s3_bucket" "dynamic_contents_bucket" {
  bucket = local.computed_dynamic_contents_bucket_name

  tags = local.common_tags
}

resource "aws_s3_bucket_cors_configuration" "dynamic_content_cors_config" {
  bucket = aws_s3_bucket.dynamic_contents_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [
      "GET",
      "PUT",
      "DELETE",
    "HEAD"]
    allowed_origins = ["*"]

    max_age_seconds = 3000
  }
}
