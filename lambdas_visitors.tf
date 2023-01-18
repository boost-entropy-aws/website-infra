module "visitor_log_entry_lambda" {
  source        = "./lambdas"
  function_name = "VisitorLogEntry"
  source_bucket = var.lambda_source_bucket
  source_key    = var.visitor_log_entry_source_key
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

  handler              = var.visitor_log_entry_handler_name
  function_url_enabled = true
  app_name             = var.app_name
  environment_variables = {
    table_name  = var.dynamodb_table_name
    region_name = var.region

  }
   runtime = "go1.x"
}

module "visitors_ddb_update_handler" {
  source        = "./lambdas"
  function_name = "VisitorsDdbUpdateHandler"
  source_bucket = var.lambda_source_bucket
  source_key    = var.visitor_update_stats_source_key
  handler       = var.visitor_update_stats_handler_name
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
       
        "dynamodb:GetItem",
        "dynamodb:PutItem"
       
      ],
      "Resource": [
        "${aws_dynamodb_table.stats_dynamodb_table.arn}"
        
      ]
    }
    
  ]
}
EOF
 

  function_url_enabled = false
  app_name             = var.app_name
  environment_variables = {
  
    table_name   = var.stats_dynamodb_table_name
    region_name  = var.region
    

  }
  runtime = "go1.x"
}