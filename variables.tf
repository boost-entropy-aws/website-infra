variable "prefix" {
  default = "cdg"
}
variable "profile" {
  type    = string
  default = "default"
}
variable "region" {
  default = "us-east-1"

}
variable "app_name" {
  default = "cdg"

}
variable "domain_name" {
  type = string
}


variable "dynamodb_table_name" {
  type    = string
  default = "CdgDynamicContents"

}
variable "stats_dynamodb_table_name"{
  type = string
  default = "CdgWebsiteStatistics"

}