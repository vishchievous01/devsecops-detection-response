terraform {
  required_version = ">= 1.6.0"
}

resource "aws_s3_bucket" "devsecops_demo" {
  bucket = "devsecops-demo-security-test"

  tags = {
    Project = "devsecops-detection-response"
  }
}
