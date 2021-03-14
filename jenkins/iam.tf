# Get the assume role policy document
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "AllowEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create an IAM role for the master instance
resource "aws_iam_role" "ssm_role" {
  name               = "ssm_role_for_ec2"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = merge(
    {
      Name = "jenkins_master_role"
      Type = "IAM Role"
    },
    var.tags
  )
}

# Attach the SSM policy to the master instance role
resource "aws_iam_role_policy_attachment" "attach_policy_to_ssm_role" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
