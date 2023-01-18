resource "aws_lambda_event_source_mapping" "blogontentstreammapping" {
  event_source_arn  = aws_dynamodb_table.dynamodb_table.stream_arn
  function_name     = module.blogs_ddb_update_handler.function_arn
  starting_position = "LATEST"

  filter_criteria {
    filter {
      pattern = jsonencode({

        dynamodb : { Keys : { pk : { S : ["blogs"] } } }


      })
    }
  }

}

resource "aws_lambda_event_source_mapping" "testimonialcontentstreammapping" {
  event_source_arn  = aws_dynamodb_table.dynamodb_table.stream_arn
  function_name     = module.testimonial_ddb_update_handler_lambda.function_arn
  starting_position = "LATEST"

  filter_criteria {
    filter {
      pattern = jsonencode({

        dynamodb : { Keys : { pk : { S : ["testimonials"] } } }


      })
    }
  }

}

resource "aws_lambda_event_source_mapping" "visitorstreammapping" {
  event_source_arn  = aws_dynamodb_table.dynamodb_table.stream_arn
  function_name     = module.visitors_ddb_update_handler.function_arn
  starting_position = "LATEST"

  filter_criteria {
    filter {
      pattern = jsonencode({

        dynamodb : { Keys : { pk : { S : ["users"] } } }


      })
    }
  }

}
