# Existing VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# Existing Subnet
data "aws_subnet" "existing" {
  id = var.subnet_id
}

# Existing Internet Gateway attached to that VPC
data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

resource "aws_s3_bucket" "static_site" {
  bucket = "atharva-static-site-${random_id.suffix.hex}" # ensure uniqueness
  tags   = { Name = "StaticWebsite" }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.static_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

data "aws_iam_policy_document" "public_read_policy" {
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.static_site.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.public_read_policy.json
}

resource "random_id" "suffix" {
  byte_length = 4
}
