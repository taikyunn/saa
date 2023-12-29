# ハンズオン13の環境を作成するためのコード
resource "aws_instance" "this" {
  instance_type = "t2.micro"
  tags = {
    "Name" = "TestInstanceForMetrics"
  }
  ami                  = data.aws_ssm_parameter.amazonlinux_2.value
  iam_instance_profile = aws_iam_instance_profile.this.name
}

data "aws_ssm_parameter" "amazonlinux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2" # x86_64
  # name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-arm64-gp2" # ARM
  # name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-minimal-hvm-x86_64-ebs" # Minimal Image (x86_64)
  # name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-minimal-hvm-arm64-ebs" # Minimal Image (ARM)
}

resource "aws_iam_instance_profile" "this" {
  name = "TestInstanceForMetricsRole"
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
  name               = "test_role_for_cw_metrics"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "cw_agent_server_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy_attachment" "this" {
  name       = "CloudWatchAgentServerPolicy"
  policy_arn = data.aws_iam_policy.cw_agent_server_policy.arn
  roles      = [aws_iam_role.role.name]
}

# CWアラームの作成
resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = "testAlarmForEC2"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "latency"
  datapoints_to_alarm = 1
  dimensions = {
    "InstanceId"   = aws_instance.this.id
    "InstanceType" = aws_instance.this.instance_type
  }
  insufficient_data_actions = []
  namespace                 = "testMetricsLatency"
  ok_actions                = []
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 30
  alarm_actions             = ["arn:aws:swf:ap-northeast-1:926330672208:action/actions/AWS_EC2.InstanceId.Stop/1.0"]
}
