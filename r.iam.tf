# tfcloud-oidc-iam Module - AWS IAM Resources

resource aws_iam_openid_connect_provider default {
  url = var.url
  client_id_list = var.sts_endpoints
  thumbprint_list = length(var.thumbprint_list) == 0 ? [local.tfcloud_oidc_fingerprint] : var.thumbprint_list
  tags = var.tags
}