# iam_group
resource "aws_iam_group" "this_group" {
  name = "cmtr-6pajwelx-iam-group"
  path = "/users/"
}

resource "aws_iam_policy" "this_policy" {
  name        = "cmtr-6pajwelx-iam-policy"
  path        = "/"
  description = "My s3 bucket policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = templatefile(
    "${path.module}/policy.json",
    {
      bucket_name = var.bucket_name
  })

}

data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "this_role" {
  name = "cmtr-6pajwelx-iam-role"

  managed_policy_arns = [aws_iam_policy.this_policy.arn]
  assume_role_policy  = data.aws_iam_policy_document.ec2_trust_policy.json
}

resource "aws_iam_policy_attachment" "this_attachment" {
  name  = "cmtr-6pajwelx-iam-attachment"
  roles = [aws_iam_role.this_role.name]
  #groups     = [aws_iam_group.group.name]
  policy_arn = aws_iam_policy.this_policy.arn
}

resource "aws_iam_instance_profile" "this_profile" {
  name = "cmtr-6pajwelx-iam-instance-profile"
  role = aws_iam_role.this_role.name
}

