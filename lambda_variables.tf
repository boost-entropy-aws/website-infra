variable "from_mail_id" {
  type = string
}
variable "to_mail_id" {
  type = string
}
variable "lambda_source_bucket" {
  type = string
}
variable "add_testimonial_source_key" {
  type = string
}

variable "add_testimonial_handler_name" {
  type = string
}


variable "testimonial_ddb_update_handler_source_key" {
  type = string
}
variable "testimonial_ddb_update_handler_name" {
  type = string

}
variable "blogs_ddb_update_event_handler_source_key" {
  type = string

}
variable "blogs_ddb_update_event_handler_name" {
  type = string

}
variable "list_blogs_handler_source_key" {
  type = string

}
variable "list_blogs_handler_name" {
  type = string

}
variable "blog_upload_handler_source_key" {
  type = string

}
variable "blog_upload_handler_name" {
  type = string

}
variable "visitor_log_entry_source_key" {
  type = string

}
variable "visitor_log_entry_handler_name" {
  type = string

}

variable "visitor_update_stats_source_key" {
  type = string

}
variable "visitor_update_stats_handler_name" {
  type = string

}

variable "cognito_preauth_handler_source_key" {
  type = string

}

variable "cognito_preauth_handler_name" {
  type = string

}
variable "token_variable_name" {
  type = string

}



