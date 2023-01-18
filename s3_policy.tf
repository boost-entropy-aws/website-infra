data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.websitebucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cdg_distribution.id}"]
    }


  }

}



resource "aws_s3_bucket_policy" "websitebucket" {
  bucket = aws_s3_bucket.websitebucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}


data "aws_iam_policy_document" "dynamic_content_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.dynamic_contents_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cdg_distribution.id}"]
    }


  }
  statement {
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.dynamic_contents_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [module.testimonial_ddb_update_handler_lambda.lambda_role_arn]
    }



  }
  statement {
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.dynamic_contents_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cdg_admin_role.arn]
    }

  }
  statement {
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.dynamic_contents_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [module.blog_upload_event_handler_lambda.lambda_role_arn]
    }



  }
}
resource "aws_s3_bucket_policy" "dynamic_contents_bucket" {
  bucket = aws_s3_bucket.dynamic_contents_bucket.id
  policy = data.aws_iam_policy_document.dynamic_content_s3_policy.json
}
