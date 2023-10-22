resource "aws_cloudfront_origin_access_control" "cdg" {
  name                              = "cdg"
  description                       = "CDG OAC Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdg_distribution" {

  origin {
    domain_name              = aws_s3_bucket.websitebucket.bucket_regional_domain_name
    origin_id                = "S3-${local.computed_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.cdg.id
  }

  origin {
    domain_name              = aws_s3_bucket.dynamic_contents_bucket.bucket_regional_domain_name
    origin_id                = "S3-${local.computed_dynamic_contents_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.cdg.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["${var.prefix}.${var.domain_name}"]



  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${local.computed_bucket_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 604800
    default_ttl            = 604800
    max_ttl                = 604800
    compress               = true
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewerfunction.arn
    }
  }
  ordered_cache_behavior {
    path_pattern     = "/dynamic/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${local.computed_dynamic_contents_bucket_name}"

    default_ttl = 3600
    min_ttl     = 3600
    max_ttl     = 3600
    compress    = true
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }
  ordered_cache_behavior {
    path_pattern     = "/blogs/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${local.computed_dynamic_contents_bucket_name}"

    default_ttl = 604800
    min_ttl     = 604800
    max_ttl     = 604800
    compress    = true
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = local.common_tags
}
resource "aws_cloudfront_function" "viewerfunction" {
  name    = "astro_fn"
  runtime = "cloudfront-js-1.0"
  comment = "Function for supporting file name based routes"
  publish = true
  code    = file("${path.module}/functions/main.js")
}
output "distribution_id" {
  value = aws_cloudfront_distribution.cdg_distribution.id
}
output "cf_domain_name" {
  value = aws_cloudfront_distribution.cdg_distribution.domain_name
}
