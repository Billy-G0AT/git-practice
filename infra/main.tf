provider "aws" {
  region = "us-west-1"
}

#* Domain Bucket
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

#* Bucket Index File
resource "aws_s3_bucket_website_configuration" "hcl-domain-webconfig" {
  bucket = var.bucket_name
  index_document {
    suffix = "index.html"
  }
}

#* Domain Bucket Allow Public Access (add this to subdomain bucket too)
resource "aws_s3_bucket_public_access_block" "hcl-bucket-public-access" {
  bucket                  = var.bucket_name
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#* Domain Policy Document
data "aws_iam_policy_document" "hcl-domain-policy-doc" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
  }
}

#* Domain Bucket Policy
resource "aws_s3_bucket_policy" "hcl-domain-policy" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.hcl-domain-policy-doc.json
}
