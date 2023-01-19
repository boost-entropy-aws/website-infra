resource "aws_iam_role" "cdg_admin_role" {
  name = "cdg_admin_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "cognito-identity.amazonaws.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity_pool.id}"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy" "cdg_admin_policy" {
  name        = "admin-policy"
  description = "Admin access policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       
        {
            "Sid": "AccessS3Policy",
            "Effect": "Allow",
            "Action": [
                "s3:*"

            ],
            "Resource": "${aws_s3_bucket.dynamic_contents_bucket.arn}"
        },
        {
          "Effect": "Allow",
          "Action": [
          
            "dynamodb:GetItem",
            "dynamodb:Query"
          
          ],
          "Resource": [
            "${aws_dynamodb_table.stats_dynamodb_table.arn}"
            
          ]
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cdg_admin_policy-attach" {
  role       = aws_iam_role.cdg_admin_role.name
  policy_arn = aws_iam_policy.cdg_admin_policy.arn
}

resource "aws_cognito_user_group" "admin" {

  name        = "Admin"
  description = "Group for Admin"

  role_arn     = aws_iam_policy.cdg_admin_policy.arn
  user_pool_id = module.cognito_user_pool.id
}
resource "aws_cognito_identity_pool_roles_attachment" "myaws" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id
  roles = {
    "authenticated" : aws_iam_role.cdg_member_role.arn


  }
  role_mapping {
    identity_provider         = "${module.cognito_user_pool.endpoint}:${module.cognito_user_pool.client_ids[0]}"
    ambiguous_role_resolution = "AuthenticatedRole"
    type                      = "Rules"
    # role-based access based on AD group
    mapping_rule {
      claim      = "cognito:groups"
      match_type = "Contains"
      role_arn   = aws_iam_role.cdg_admin_role.arn
      value      = "Admin"
    }
    mapping_rule {
      claim      = "cognito:groups"
      match_type = "Contains"
      role_arn   = aws_iam_role.cdg_member_role.arn
      value      = "Member"
    }
  }

}