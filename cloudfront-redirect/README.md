# How to setup redirects 
this should show how to create aws lambda function for redirects
## dependencies 
* EC2 instance or any vps that hosts your site
* Load balancer for the EC2 instances
* Cloudfront distribution that's linked to the Load balancer
* S3 bucket with the redirect json
## lambda@edge function
1. go to `console.aws.amazon.com/lambda/home`
2. click create function
3. use a blueprint cloudfront-http-redirect
4. add function name and click add
5. publish the first version
6. add the Cloudfront trigger