# URL Shortener Service

## Prerequisites
1. Terraform  [Download Link](https://www.terraform.io/downloads.html)
2. AWS Account
3. Jenkins ( Optional for CI/CD)


## Run the program 

First clone this repo

    git clone https://github.com/hypunit/09062023.git 
    
Intilize the provide plugins 

    terraform init
    
Plan the deployment before building stack

    terraform plan
    
Apply building stack

    terraform apply
   
If you wish to destory all the resources that terraform created, use this

    terraform destroy
    
## Deploy via Jenkins

Copy the Jenkinsfile and paste in your Jenkins Server > JOBS > config.xml > script section

## How to use?

After succefully build stack, you will get an API endpoint as an output.

you can use any of your favourite programming language  to interact with API , i used postman to post a request to API.

If using postman,

In url box, Enter the API endpoint followed by /app such as : /dev

Select method as POST. In Body select raw and type json

Enter sample input:

    {
    "long_url":"http://google.com",
    "id":"google"
    }
    
now when you hit send button, You will get http 200 response when data added to dynamodb database 

#### Verification Step 

Paste the API endpoint in browser followed by key i.e. google in this case (use your api endpoint here)

    https://<apikey>.execute-api.us-east-1.amazonaws.com/dev/google

you will redirected to google.com (which is your long_url).
