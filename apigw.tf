# rest API
resource "aws_api_gateway_rest_api" "short-url-api" {
  name        = "short-url-api"
  description = "Url shortener rest API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# app resource to add data into database
resource "aws_api_gateway_resource" "app" {
  rest_api_id = aws_api_gateway_rest_api.short-url-api.id
  parent_id   = aws_api_gateway_rest_api.short-url-api.root_resource_id
  path_part   = "app"
}

# post call in app resource
resource "aws_api_gateway_method" "app-post" {
  rest_api_id   = aws_api_gateway_rest_api.short-url-api.id
  resource_id   = aws_api_gateway_resource.app.id
  http_method   = "POST"
  authorization = "NONE"
}

#  api gateway integration 
resource "aws_api_gateway_integration" "app-post-ireq" {
  rest_api_id             = aws_api_gateway_rest_api.short-url-api.id
  resource_id             = aws_api_gateway_resource.app.id
  http_method             = aws_api_gateway_method.app-post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:ap-south-1:dynamodb:action/UpdateItem"

  credentials = aws_iam_role.write-role.arn

  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
    {
      "TableName": "short-url",
      "ConditionExpression": "attribute_not_exists(id)",
      "Key": {
        "id": {
          "S": $input.json('$.id')
        }
      },
      "ExpressionAttributeNames": {
        "#u": "long_url",
        "#ts": "timestamp"
      },
      "ExpressionAttributeValues": {
        ":u": {
          "S": $input.json('$.long_url')
        },
        ":ts": {
          "S": "$context.requestTime"
        }
      },
      "UpdateExpression": "SET #u = :u, #ts = :ts",
      "ReturnValues": "ALL_NEW"
    }
EOF
  }
}

#  response code for post call in app resource
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.short-url-api.id
  resource_id = aws_api_gateway_resource.app.id
  http_method = aws_api_gateway_method.app-post.http_method
  status_code = "200"
}

# integration response for post call in app resource
resource "aws_api_gateway_integration_response" "app-post-ires" {
  rest_api_id = aws_api_gateway_rest_api.short-url-api.id
  resource_id = aws_api_gateway_resource.app.id
  http_method = aws_api_gateway_method.app-post.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    {
      "id": "$inputRoot.Attributes.id.S",
      "long_url": "$inputRoot.Attributes.long_url.S",
      "timestamp": "$inputRoot.Attributes.timestamp.S",
    }
EOF
  }
}

#------------------------------------------------
# Method {id} for querying key into database
#-------------------------------------------------

# id resource
resource "aws_api_gateway_resource" "id1" {
  rest_api_id = aws_api_gateway_rest_api.short-url-api.id
  parent_id   = aws_api_gateway_rest_api.short-url-api.root_resource_id
  path_part   = "{id}"
}

# using get http method here so that we can query the database form browser
resource "aws_api_gateway_method" "id1-post" {
  rest_api_id   = aws_api_gateway_rest_api.short-url-api.id
  resource_id   = aws_api_gateway_resource.id1.id
  http_method   = "GET"
  authorization = "NONE"
}

# integration request to accept key in header
resource "aws_api_gateway_integration" "id1-post-ireq" {
  rest_api_id             = aws_api_gateway_rest_api.short-url-api.id
  resource_id             = aws_api_gateway_resource.id1.id
  http_method             = aws_api_gateway_method.id1-post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:ap-south-1:dynamodb:action/GetItem"

  credentials = aws_iam_role.read-role.arn

  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
    {
  "Key": {
    "id": {
      "S": "$input.params().path.id"
    }
  },
  "TableName": "short-url"
}
EOF
  }
}

# Using 304 response here so that it will directtly redirect the user to location
resource "aws_api_gateway_method_response" "response_304" {
  rest_api_id         = aws_api_gateway_rest_api.short-url-api.id
  resource_id         = aws_api_gateway_resource.id1.id
  http_method         = aws_api_gateway_method.id1-post.http_method
  status_code         = "304"
  response_parameters = { "method.response.header.Location" = true }
}

# integration response for query
resource "aws_api_gateway_integration_response" "id1-post-ires" {
  rest_api_id = aws_api_gateway_rest_api.short-url-api.id
  resource_id = aws_api_gateway_resource.id1.id
  http_method = aws_api_gateway_method.id1-post.http_method
  status_code = aws_api_gateway_method_response.response_304.status_code

  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
#if ($inputRoot.toString().contains("Item"))
  #set($context.responseOverride.header.Location = $inputRoot.Item.long_url.S)
#end
EOF
  }
}

# deplyoing the API to prod stage
resource "aws_api_gateway_deployment" "prod-api" {
  depends_on = [aws_api_gateway_integration.id1-post-ireq]

  rest_api_id = aws_api_gateway_rest_api.short-url-api.id
  stage_name  = var.environment
}
