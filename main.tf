/**
 * AWS SNS Terraform Module
 * =====================
 *
 * Create AWS SNS topic and set policy
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

# TODO: Add namespacing

// AWS Account Id
data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "this" {
  count         = "${length(var.names)}"
  name          = "${element(var.names, count.index)}"
  display_name  = "${replace(element(var.names, count.index), "-", "")}"
  # policy - Use policy cmd instead
  # delivery_policy # For http
}

resource "aws_sns_topic_policy" "default" {
  count   = "${length(var.names)}"
  arn     = "${element(aws_sns_topic.this.*.arn, count.index)}"
  policy  = "${element(data.aws_iam_policy_document.sns-topic-policy.*.json, count.index)}"
}

# This does not support email
#resource "aws_sns_topic_subscription" {}

data "aws_iam_policy_document" "sns-topic-policy" {
  # Not allowed to use count?? Need to put in topic? :( How to ref arn?
  count   = "${length(var.names)}"
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
