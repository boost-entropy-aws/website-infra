variable "source_bucket" {
  type = string

}
variable "source_key" {
  type = string

}
variable "policy" {

default = ""
}
variable "function_name" {
  type = string
}
variable "handler" {

}
variable "function_url_enabled" {
  default = false

}
variable "app_name" {

}
variable "environment_variables" {
  default = {}

}
variable "runtime" {

}
variable "additional_policy" {
  default = true
  
}
