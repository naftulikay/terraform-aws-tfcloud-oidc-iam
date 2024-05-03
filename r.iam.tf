# tfcloud-oidc-iam Module - AWS IAM Resources

resource aws_iam_openid_connect_provider default {
  url = var.url
  # FIXME this is the original value copied from the gha module
  # client_id_list = var.sts_endpoints
  # this is what terraform cloud docs suggest
  client_id_list = ["aws.workload.identity"]
  thumbprint_list = length(var.thumbprint_list) == 0 ? [local.tfcloud_oidc_fingerprint] : var.thumbprint_list
  tags = var.tags
}