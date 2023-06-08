# I choose to use dynamo db read and write capacity quite low just to make it under free tier.
# you may increase the read write capacity but it will add costs.
resource "aws_dynamodb_table" "default" {
  name           = "short-url"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
  tags = {
    Name        = "short-url"
    Environment = "Dev"
  }

}
