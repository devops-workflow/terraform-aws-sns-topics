AWS SNS Terraform module
========================

Terraform module which creates SNS topics on AWS.

Usage
-----

```hcl
module "sns-topics" {
  source      = "devops-workflow/sns/aws"
  names       = ["topic-1", "topic2", "topic_3"]
  environment = "dev"
}
```
