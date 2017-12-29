/**
 * AWS SNS Terraform Module
 * =====================
 *
 * Create multiple AWS SNS topics and set policies
 *
 * Usage:
 * ------
 * '''hcl
 *     module "sns" {
 *       source       = "../sns"
 *       names        = ["Topic-1", "Topic2"]
 *     }
 * '''
**/
# https://www.terraform.io/docs/providers/aws/r/aws_sns_topic.html
# https://www.terraform.io/docs/providers/aws/r/aws_sns_topic_policy.html
# https://www.terraform.io/docs/providers/aws/r/aws_sns_topic_subscription.html

module "enabled" {
  source  = "devops-workflow/boolean/local"
  version = "0.1.1"
  value   = "${var.enabled}"
}
/*
module "label" {
  source        = "devops-workflow/label/local"
  version       = "0.1.3"
  organization  = "${var.organization}"
  name          = "${var.name}"
  namespace-env = "${var.namespace-env}"
  namespace-org = "${var.namespace-org}"
  environment   = "${var.environment}"
  delimiter     = "${var.delimiter}"
  attributes    = "${var.attributes}"
  tags          = "${var.tags}"
}
*/

// AWS Account Id
data "aws_caller_identity" "current" {
  count         = "${module.enabled.value}"
}

resource "aws_sns_topic" "this" {
  count         = "${module.enabled.value ? length(var.names) : 0}"
  name          = "${var.namespaced ?
    format("%s-%s", var.environment, element(var.names, count.index)) :
    format("%s", element(var.names, count.index))}"
  display_name  = "${var.namespaced ?
    format("%s-%s", var.environment, replace(element(var.names, count.index), "-", "")) :
    format("%s", replace(element(var.names, count.index), "-", ""))}"
  # policy - Use policy cmd instead
  # delivery_policy # For http
}

resource "aws_sns_topic_policy" "default" {
  count   = "${module.enabled.value ? length(var.names) : 0}"
  arn     = "${element(aws_sns_topic.this.*.arn, count.index)}"
  policy  = "${element(data.aws_iam_policy_document.sns-topic-policy.*.json, count.index)}"
}

# This does not support email
#resource "aws_sns_topic_subscription" {}

data "aws_iam_policy_document" "sns-topic-policy" {
  # Not allowed to use count?? Need to put in topic? :( How to ref arn?
  count   = "${module.enabled.value ? length(var.names) : 0}"
  policy_id = "__default_policy_ID"
  statement {
    actions = [
      "SNS:AddPermission",
      "SNS:DeleteTopic",
      "SNS:GetTopicAttributes",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive",
      "SNS:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:Subscribe",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        "${data.aws_caller_identity.current.account_id}",
      ]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "${element(aws_sns_topic.this.*.arn, count.index)}",
    ]
    sid = "__default_statement_ID"
  }
}
