// Role for API to write data into dynamodb table
resource "aws_iam_role" "write-role" {
  name               = "write-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "write-iam-instance-profile" {
  name = "write-iam-instance-profile"
  role = aws_iam_role.write-role.name
}

#  inline policy for write role
resource "aws_iam_role_policy" "write-policy" {
  name = "write-policy"
  role = aws_iam_role.write-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "UserRW",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ],
        "Resource" : "*"
      }
    ]
  })
}

// Role for API to read data from dynamodb table
resource "aws_iam_role" "read-role" {
  name               = "read-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "read-iam-instance-profile" {
  name = "read-iam-instance-profile"
  role = aws_iam_role.read-role.name
}

# inline policy for read role 
resource "aws_iam_role_policy" "read-policy" {
  name = "read-policy"
  role = aws_iam_role.read-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "UserRO",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query"
        ],
        "Resource" : "*"
      }
    ]
  })
}
