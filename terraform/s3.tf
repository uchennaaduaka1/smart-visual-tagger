resource "aws_s3_bucket" "image_bucket" {
  bucket = var.bucket_name
  force_destroy = true
}

output "bucket_name" {
  value = aws_s3_bucket.image_bucket.id
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "allow_rekognition_access" {
  bucket = aws_s3_bucket.image_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Sid: "AllowRekognitionFullReadAccess",
        Effect: "Allow",
        Principal: {
          Service: "rekognition.amazonaws.com"
        },
        Action: [
          "s3:GetObject"
        ],
        Resource: "${aws_s3_bucket.image_bucket.arn}/*"
      }
    ]
  })
}

