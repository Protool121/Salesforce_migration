

data "aws_s3_bucket" "bucket" {
  bucket = "salesrunner"
}



resource "aws_sqs_queue" "sqsdev-temp" {
  name                      = "salesrunner_sqs"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  policy = data.aws_iam_policy_document.sns_topic_policy.json
  tags = {
    Environment = "Salesrunner"
  }
}


data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }


    sid = "__default_statement_ID"
  }
}


resource "aws_sqs_queue" "queue" {
  name = "s3-event-notification-queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:s3-event-notification-queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${data.aws_s3_bucket.bucket.arn}" }
      }
    }
  ]
}
POLICY
}


# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = data.aws_s3_bucket.bucket.id

#   queue {
#     queue_arn     = aws_sqs_queue.sqsdev-temp.arn
#     events        = ["s3:ObjectCreated:*"]
#   }
# }


