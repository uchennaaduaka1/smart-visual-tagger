resource "aws_dynamodb_table" "image_labels" {
  name           = "ImageLabels"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "image"

  attribute {
    name = "image"
    type = "S"
  }
}