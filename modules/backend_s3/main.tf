resource "aws_s3_bucket" "backend" {
  bucket = "saa-test-tf-state"
  tags = {
    Name = "saa-test-tf-state"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.backend.id

  rule {
    id     = "remove-30-days"
    status = "Enabled"

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 31
    }
  }
}
