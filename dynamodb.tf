resource "aws_dynamodb_table" "dynamodb_table" {

  name             = var.dynamodb_table_name
  hash_key         = "pk"
  range_key        = "sk"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "KEYS_ONLY"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = local.common_tags
}
output "dynamodb_arn" {
  value = aws_dynamodb_table.dynamodb_table.arn

}

resource "aws_dynamodb_table" "stats_dynamodb_table" {

  name             = var.stats_dynamodb_table_name
  hash_key         = "pk"
  range_key        = "sk"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = local.common_tags
}

