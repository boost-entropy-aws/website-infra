
// Invoked when new testimonial is added. Inserts an item to dynamodb with pk tesimonials
module "add_testimonial_lambda" {
  source        = "./lambdas"
  function_name = "AddTestimonial"
  source_bucket = var.lambda_source_bucket
  source_key    = var.add_testimonial_source_key
  policy        = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [        
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "${aws_dynamodb_table.dynamodb_table.arn}"
    }
  ]
}
EOF

  handler              = var.add_testimonial_handler_name
  function_url_enabled = true
  app_name             = var.app_name
  environment_variables = {
    table_name  = var.dynamodb_table_name
    region_name = var.region

  }
  runtime = "java11"
}
//This lambda is to update S3 file once new testimonial is updated. DynamoDB is queried to get all testimonials
module "testimonial_ddb_update_handler_lambda" {
  source        = "./lambdas"
  function_name = "TestimonialDDBUpdateHandler"
  source_bucket = var.lambda_source_bucket
  source_key    = var.testimonial_ddb_update_handler_source_key
  handler       = var.testimonial_ddb_update_handler_name
    policy        = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
       
        "dynamodb:Query"
       
      ],
      "Resource": [
        "${aws_dynamodb_table.dynamodb_table.arn}"
        
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:DescribeStream",
        "dynamodb:ListStreams"
      ],
      "Resource": [
        "${aws_dynamodb_table.dynamodb_table.arn}",
        "${aws_dynamodb_table.dynamodb_table.arn}/stream/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${local.computed_dynamic_contents_bucket_name}",
        "arn:aws:s3:::${local.computed_dynamic_contents_bucket_name}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
 


  function_url_enabled = false
  app_name             = var.app_name
  environment_variables = {
    table_name   = var.dynamodb_table_name
    region_name  = var.region
    bucket_name  = local.computed_dynamic_contents_bucket_name
    file_name    = "dynamic/testimonials.json"
    from_mail_id = var.from_mail_id
    to_mail_id   = var.to_mail_id
  }
   runtime = "go1.x"
}


// Invoked when records are updated to DynamoDB. This initiates the github workflow for main website to generate the routes
module "blogs_ddb_update_handler" {
  source        = "./lambdas"
  function_name = "BlogsDdbUpdateHandler"
  source_bucket = var.lambda_source_bucket
  source_key    = var.blogs_ddb_update_event_handler_source_key
  handler       = var.blogs_ddb_update_event_handler_name
  policy=<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:DescribeStream",
        "dynamodb:ListStreams"
      ],
       "Resource": [
        "${aws_dynamodb_table.dynamodb_table.arn}",
        "${aws_dynamodb_table.dynamodb_table.arn}/stream/*"
      ]
    },
     {
      "Effect": "Allow",
      "Action": [
       
        "dynamodb:Query"
       
      ],
      "Resource": [
        "${aws_dynamodb_table.dynamodb_table.arn}"
        
      ]
    },
     {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${local.computed_dynamic_contents_bucket_name}",
        "arn:aws:s3:::${local.computed_dynamic_contents_bucket_name}/*"
      ]
    },
   
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters", "ssm:GetParameter", "ssm:GetParameterHistory", "ssm:GetParametersByPath"
      ],
      "Resource": [
        "arn:aws:ssm:${var.region}:${data.aws_caller_identity.default.account_id}:parameter/${var.token_variable_name}"
       
      ]
    }
  ]
}
EOF
 


  function_url_enabled = false
  app_name             = var.app_name
  environment_variables = {
    repo_name          = "main-website-frontend"
    owner_name         = "cdgbabies"
    workflow_file_name = "deploy.yml"
    branch             = "main"
    token_name         = var.token_variable_name
    table_name   = var.dynamodb_table_name
    region_name  = var.region
    bucket_name  = local.computed_dynamic_contents_bucket_name
     file_name    = "dynamic/blogs.json"

  }
  runtime = "go1.x"
}
//Invoked to get the list of blogs
module "list_blogs" {
  source        = "./lambdas"
  function_name = "ListBlogs"
  source_bucket = var.lambda_source_bucket
  source_key    = var.list_blogs_handler_source_key
  handler       = var.list_blogs_handler_name
  policy        = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
   {
        "Effect": "Allow",
        "Action": [
         
          "dynamodb:Query"
         
        ],
        "Resource": [
          "${aws_dynamodb_table.dynamodb_table.arn}"
          
        ]
      }
  ]
}
EOF
  


  function_url_enabled = true
  app_name             = var.app_name
  environment_variables = {
    region_name = var.region,
    table_name  = var.dynamodb_table_name

  }
  runtime = "go1.x"
}
// Lambda invoked when a new blog is uploaded to S3 . It creates a new item in DynamoDB

module "blog_upload_event_handler_lambda" {
  source        = "./lambdas"
  function_name = "BlogsUploadEventHandler"
  source_bucket = var.lambda_source_bucket
  source_key    = var.blog_upload_handler_source_key
    policy        = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [         
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        "Resource": "${aws_dynamodb_table.dynamodb_table.arn}"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": [
          "arn:aws:s3:::${local.computed_dynamic_contents_bucket_name}",
          "arn:aws:s3:::${local.computed_dynamic_contents_bucket_name}/*"
        ]
      }
  ]
}
EOF
 

  handler              = var.blog_upload_handler_name
  function_url_enabled = false
  app_name             = var.app_name
  environment_variables = {
    table_name  = var.dynamodb_table_name
    region_name = var.region

  }
  runtime = "java11"
}


resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.blog_upload_event_handler_lambda.function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.dynamic_contents_bucket.arn
}





resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = local.computed_dynamic_contents_bucket_name

  lambda_function {
    lambda_function_arn = module.blog_upload_event_handler_lambda.function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "blogs/"

  }

  depends_on = [aws_lambda_permission.allow_bucket]
}