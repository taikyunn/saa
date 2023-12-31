# CollcetD Install(-2022)
sudo amazon-linux-extras install collectd
# CollectD Install(2023)
sudo yum install collectd
# Install CloudWatch Agent(2023)
sudo yum install amazon-cloudwatch-agent
# CloudWatch Anaget Congfiguration with wizard
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
# Fetch Config file
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
# Start CloudWatch Agent
sudo systemctl start amazon-cloudwatch-agent
# 詳細
https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html
