/**resource "aws_ses_email_identity" "email_ses" {
  email = "a.pavithraa@gmail.com"
}
*/
module "cognito_user_pool" {

  source                   = "lgallard/cognito-user-pool/aws"
  version                  = "0.19.0"
  user_pool_name           = "${var.app_name}_pool"
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  email_configuration = {
    email_sending_account  = "DEVELOPER"
    reply_to_email_address = var.reply_to_email_address
    source_arn             = "arn:aws:ses:us-east-1:${data.aws_caller_identity.default.account_id}:identity/a.pavithraa@gmail.com"
  }

  lambda_config = {

    pre_sign_up = module.presignup_cognito.function_arn

  }

  password_policy = {
    minimum_length                   = 10
    require_lowercase                = false
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 120

  }

  admin_create_user_config_allow_admin_create_user_only = false

  # clients
  clients = [
    {
      allowed_oauth_flows                  = ["code", "implicit"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes                 = ["email", "openid", "aws.cognito.signin.user.admin", "profile"]
      callback_urls                        = [var.callback_url]
      default_redirect_uri                 = var.redirect_url
      explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
      generate_secret                      = false
      logout_urls                          = [var.logout_url]
      name                                 = "${var.prefix}_client"
      supported_identity_providers         = ["COGNITO"]
      refresh_token_validity               = 30
    }

  ]





  # tags
  tags = {
    Owner       = "infra"
    Environment = "production"
    Terraform   = true
  }
}
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "cdgnew"
  user_pool_id = module.cognito_user_pool.id
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "${var.app_name}_identity_pool"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false

  cognito_identity_providers {
    client_id               = module.cognito_user_pool.client_ids[0]
    provider_name           = module.cognito_user_pool.endpoint
    server_side_token_check = false
  }


}