# ハンズオン17の環境を作成するためのコード
resource "aws_cloudtrail" "this" {
  depends_on = [aws_s3_bucket_policy.this]

  name                          = "test-management-event"
  s3_bucket_name                = aws_s3_bucket.this.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  tags = {
    "Name" = "test-management-event"
  }
}

resource "aws_s3_bucket" "this" {
  bucket        = "cloudtrail-logs-123456789012"
  force_destroy = true
}

# S3イベント通知
resource "aws_lambda_permission" "this1" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.this.arn
}

resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".json"
  }
  depends_on = [ aws_lambda_permission.this1 ]
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.this.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/test-management-event"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.this.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/test-management-event"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# snsトピックの作成(スタンダート)
resource "aws_sns_topic" "this" {
  name = "testTrailEventNotification"
  display_name = "testTrailEventNotification"
}

# snsサブスクリプションの作成
resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.this.arn
}

# lambda関数用のIAMロールを作成
data "aws_iam_policy_document" "this1" {
  statement {
    actions = [
      "logs:*",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
    ]
    effect = "Allow"

    resources = [
      "arn:aws:s3:::cloudtrail-logs-123456789012/*",
    ]
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [
      "arn:aws:sns:*:*:testTrailEventNotification",
    ]
  }
}

resource "aws_iam_policy" "this" {
  name = "trailEventlLambdaPolicy"
  policy = data.aws_iam_policy_document.this1.json
  tags = {
    "Name" = "trailEventlLambdaPolicy"
  }
}

# lambda関数用のIAMロールを作成
resource "aws_iam_role" "this" {
  name = "trailEventlLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

# lambda関数用のIAMロールにポリシーをアタッチ
data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# lambda関数の作成
resource "aws_lambda_function" "this" {
  function_name = "testTrailEventNotification"
  role          = aws_iam_role.this.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "nodejs18.x"
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_function.output_path)
  timeout       = 300
  memory_size   = 128
  tags = {
    "Name" = "testTrailEventNotification"
  }
}

data archive_file "lambda_function" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-function"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_cloudwatch_log_group" "example_log_group" {
  name = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 3
}
