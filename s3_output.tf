output "bucket_name" {
  value = local.computed_bucket_name

}
output "bucket_id" {
  value = aws_s3_bucket.dynamic_contents_bucket.id
}
