[![CircleCI](https://circleci.com/gh/devops-workflow/terraform-aws-sns-topics?style=svg)](https://circleci.com/gh/devops-workflow/terraform-aws-sns-topics)

AWS SNS Topics Terraform module
========================

Terraform module which creates SNS topics on AWS.

Terraform registry: https://registry.terraform.io/modules/devops-workflow/sns-topics/aws

Usage
-----

```hcl
module "sns-topics" {
  source      = "devops-workflow/sns-topics/aws"
  names       = ["topic-1", "topic2", "topic_3"]
  environment = "dev"
}
```
