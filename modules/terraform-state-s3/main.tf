# This is a tf module for managing the s3 bucket and dynamodb table for the terraform state store.
# The state for this tf should be stored in git.

resource "aws_kms_key" "state-key" {
  description             = "Key to encrypt statefile bucket"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "terraform-state-s3" {
  bucket = var.s3_bucket
  acl    = "private"
  
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name    = var.s3_bucket_name
    Project = var.project
    Client  = var.client
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.state-key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

resource "aws_s3_bucket_public_access_block" "block-tf-s3" {
  bucket                  = aws_s3_bucket.terraform-state-s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform" {
  name           = var.dynamodb_table
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
    ]
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = var.dynamodb_table
    Project = var.project
    Client  = var.client
  }

}
