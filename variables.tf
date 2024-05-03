# tfcloud-oidc-iam Module - Variables

variable sts_endpoints {
  type = set(string)
  default = ["sts.amazonaws.com"]
  description = <<-EOF
    A set of hostnames for Amazon's Security Token Service.

    Unless you are in GovCloud or China, you should not need to change this value from its default.
  EOF
}

variable tags {
  type = map(string)
  default = {}
  description = <<-EOF
    AWS tags to apply to the created `aws_iam_openid_connect_provider`.

    Setting tags can also be done at the provider-level using `default_tags`.
  EOF
}

variable thumbprint_list {
  type = set(string)
  default = []
  description = <<-EOF
    A set of thumbprints by which to verify OIDC access attempts.

    By default, this variable is set to an empty set, and when this is the case, this will be detected at runtime using
    the `tls` provider's `tls_certificate` data provider, grabbing the SHA-1 fingerprint of the server running at
    `url`.

    Changing this to any other value will use the user-specified values. This is entirely untested, and if you aren't
    using Terraform Enterprise, you shouldn't change/set this variable.
  EOF
}

variable url {
  type = string
  default = "https://app.terraform.io"
  description = <<-EOF
    The URL of the Terraform Cloud OIDC provider.

    You shouldn't need to modify the value of this variable unless you are using Terraform Enterprise. Support for
    Terraform Enterprise is entirely untested. This value should never have a trailing slash.
  EOF

  validation {
    condition = length(regexall("^(?:https[:][/]{2})?(?:[^:/]+)([/].*)?$", var.url)) > 0
    error_message = "var.url should not end with or contain a trailing slash/HTTP path"
  }

  validation {
    condition = startswith("https://", var.url) == false
    error_message = "var.url should start with 'https://'"
  }
}