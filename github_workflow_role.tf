module "iam_github_oidc_provider" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"

  tags = {
    Environment = "test"
  }
}
resource "aws_iam_role" "website_github_workflow_role" {
  name = "website_github_workflow_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
           "Effect": "Allow",
           "Principal": {
               "Federated": "${module.iam_github_oidc_provider.arn}"
           },
           "Action": "sts:AssumeRoleWithWebIdentity",
           "Condition": {
               "StringEquals": {
                   "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
               }
           }
       }
    ]
}
EOF
}

resource "aws_iam_policy" "website_github_workflow_policy" {
  name        = "website-github-workflow-policy"
  description = "Policy for main website github action"

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
            "Resource": ["${aws_s3_bucket.websitebucket.arn}","${aws_s3_bucket.websitebucket.arn}/*"]
          
        },
        {
          "Effect": "Allow",
          "Action": [
          
            "cloudfront:CreateInvalidation"
          
          ],
          "Resource": [
            "${aws_cloudfront_distribution.cdg_distribution.arn}"
            
          ]
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "github_policy-attach" {
  role       = aws_iam_role.website_github_workflow_role.name
  policy_arn = aws_iam_policy.website_github_workflow_policy.arn
}

output "github_role_arn"{
    value = aws_iam_role.website_github_workflow_role.arn

}