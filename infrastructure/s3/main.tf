variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  #  acl    = "private"
}

# [Data] IAM policy to define S3 permissions
# TF: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# AWS: http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
# AWS CLI: http://docs.aws.amazon.com/cli/latest/reference/iam/create-policy.html
data "aws_iam_policy_document" "s3_data_bucket_policy" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}"
    ]
  }
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
    ]
  }
}
