data "aws_iam_policy_document" "assume_authenticated_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    sid     = ""
    principals {
      identifiers = ["cognito-identity.amazonaws.com"]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = [resource.aws_cognito_identity_pool.identity_pool.id]
      variable = "cognito-identity.amazonaws.com:aud"
    }
    condition {
      test     = "ForAnyValue:StringLike"
      values   = ["authenticated"]
      variable = "cognito-identity.amazonaws.com:amr"
    }
  }
}
data "aws_iam_policy_document" "assume_unauthenticated_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    sid     = ""
    principals {
      identifiers = ["cognito-identity.amazonaws.com"]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = [resource.aws_cognito_identity_pool.identity_pool.id]
      variable = "cognito-identity.amazonaws.com:aud"
    }
    condition {
      test     = "ForAnyValue:StringLike"
      values   = ["unauthenticated"]
      variable = "cognito-identity.amazonaws.com:amr"
    }
  }
}
resource "aws_iam_role" "authenticated" {
  name               = "${var.app_name}AuthenticatedAssumeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_authenticated_role.json
}



resource "aws_iam_role" "unauthenticated" {
  name               = "${var.app_name}UnauthenticatedAssumeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_unauthenticated_role.json
}




resource "aws_iam_role" "cdg_member_role" {
  name = "cdg_member_role"

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
                    "cognito-identity.amazonaws.com:aud": "${resource.aws_cognito_identity_pool.identity_pool.id}"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy" "cdg_member_policy" {
  name        = "cdg-member-policy"
  description = "Giving S3 folder and DynamoDB Access"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       
        {
            "Sid": "DescribeQueryScanStudentsTable",
            "Effect": "Allow",
            "Action": [
                "dynamodb:ListTables",
                "dynamodb:GetItem",
                "dynamodb:BatchGetItem",
                "dynamodb:Query"

            ],
            "Resource": "${aws_dynamodb_table.dynamodb_table.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "member_policy_attach" {
  role       = aws_iam_role.cdg_member_role.name
  policy_arn = aws_iam_policy.cdg_member_policy.arn
}

resource "aws_cognito_user_group" "cdg_member_group" {

  name        = "Member"
  description = "Group for members"

  role_arn     = aws_iam_policy.cdg_member_policy.arn
  user_pool_id = module.cognito_user_pool.id
}

