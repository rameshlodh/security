# Define the S3 bucket
resource "aws_s3_bucket" "tui_sandbox_bucket" {
  bucket = "tui-sandbox-s3-end-to-end-commercial-search"

  tags = merge({
    Name = "tui-sandbox-s3-end-to-end-commercial-search"
  })
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "tui_sandbox_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.tui_sandbox_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "tui-sandbox-snowflake_sqs_notification" {
  bucket = aws_s3_bucket.tui_sandbox_bucket.id

  queue {
    events    = ["s3:ObjectCreated:*"]
    queue_arn = "arn:aws:sqs:eu-central-1:224227191538:sf-snowpipe-AIDAIV5WL2RDYQYKFAB44-bEzpzjWqyikQf6GSUNE6VA"
  }
}

# Define bucket policy to enforce secure transport and allow only root user access
resource "aws_s3_bucket_policy" "tui_sandbox_bucket_policy" {
  bucket = aws_s3_bucket.tui_sandbox_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Deny access if requests are not using secure transport (HTTPS)
      {
        Sid       = "DenyUnsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::tui-sandbox-s3-end-to-end-commercial-search",
          "arn:aws:s3:::tui-sandbox-s3-end-to-end-commercial-search/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = false
          }
        }
      }
    ]
  })
}


