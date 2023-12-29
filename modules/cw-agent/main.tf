# ハンズオン15の環境を作成するためのコード
resource "aws_instance" "this" {
  instance_type = "t2.micro"
  tags = {
    "Name" = "TestInstanceForCWAgent"
  }
  ami                  = data.aws_ssm_parameter.amazonlinux_2023.value
  iam_instance_profile = aws_iam_instance_profile.this.name
}

# amazonlinux_2023のamiはParameter Storeから取得する
data "aws_ssm_parameter" "amazonlinux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" # x86_64
  # name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-arm64" # ARM
  # name = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-6.1-x86_64" # Minimal Image (x86_64)
  # name = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-6.1-arm64" # Minimal Image (ARM)
}

resource "aws_iam_instance_profile" "this" {
  name = "TestInstanceForCWAgentRole"
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "test_cw_agent_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "cw_agent_server_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy_attachment" "this1" {
  name       = "CloudWatchAgentServerPolicy"
  policy_arn = data.aws_iam_policy.cw_agent_server_policy.arn
  roles      = [aws_iam_role.role.name]
}

data "aws_iam_policy" "ssm_managed_instance_core_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "this2" {
  name       = "AmazonSSMManagedInstanceCore"
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core_policy.arn
  roles      = [aws_iam_role.role.name]
}
