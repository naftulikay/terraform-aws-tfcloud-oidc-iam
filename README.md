# terraform-aws-tfcloud-oidc-iam [![Build Status][build.svg]][build] [![Module][module.svg]][module]

A Terraform module for AWS which sets up an IAM OpenID Connect Provider for Terraform Cloud or Terraform Enterprise.

## ⚠️ Safety ⚠️

When defining IAM assume role policies using an OIDC provider, such as one offered by this module, care must be taken
to ensure that the structure of the `:sub` field is correct. Misconfiguration can lead to situations where the role
can be assumed by entities other than expected. [Datadog details this issue on their blog][datadog-blog].

This module is, on its own, _not vulnerable to this issue_, because the onus is on the user to define IAM policy which
specifies the conditions where role assumption is allowed/denied. In short, when defining role assumption policy, be
sure to write validation tests to assert that the format of the `:sub` field is exactly what you expect, and either
avoid wildcards altogether or use them sparingly.

## Usage

This module should work out-of-the-box with no configuration required for Terraform Cloud; configuration is required for
Terraform Enterprise. For TFE, you must specify the HTTPS URL to Terraform Enterprise in the `url` variable.

If you are in GovCloud or in China, you will also need to set the `sts_endpoints` variable to the value appropriate for
these regions.

### Creating an IAM Role for Terraform Cloud/Enterprise

To use the OIDC provider in an IAM assume role policy, the following code can be used to create the OIDC provider,
generate a role assumption policy, and create an IAM role without any permissions:

```terraform
module tf_oidc_iam {
 source = "naftulikay/tfcloud-oidc-iam"
 version = "1.0.0"
}

# TODO set these to your TFC/TFE org name, project name (or wildcard), and workspace name (or wildcard)
variable tf_org { default = "my-organization-in-tfc" }
variable tf_project { default = "my-project-name-in-tfc" }
variable tf_workspace { default = "my-workspace-name-in-tfc" }

data aws_iam_policy_document assume {
 statement {
  sid = "AllowAssumeFromTerraformCloud"
  effect = "Allow"
  actions = ["sts:AssumeRoleWithWebIdentity"]

  principals {
   type = "Federated"
   identifiers = [module.tf_oidc_iam.oidc_provider_arn]
  }

  condition {
   test = "StringEquals"
   # for tfe, replace the tfcloud hostname with the tfe hostname
   variable = "app.terraform.io:aud"
   values   = ["aws.workload.identity"]
  }

  # if you can, replace this with StringEquals and an explicit list of org/project/ws/run phases
  condition {
   test = "StringLike"
   variable = "app.terraform.io:sub"
   # SAFETY you must ensure that the values of these variables are not empty and that wildcards are used carefully
   values = [
    "organization:${var.tf_org}:project:${var.tf_project}:workspace:${var.tf_workspace}:run_phase:*"
   ]
  }
 }
}

resource aws_iam_role default {
 name = "my-tfcloud-role"
 path = "/"
 assume_role_policy = data.aws_iam_policy_document.assume.json
}
```

The above code will allow plans/applies (`run_phase:*`) for the `my-workspace-name-in-tfc` workspace which is in the
`my-project-name-in-tfc` project which is in the `my-organization-in-tfc` organization.

### Configuring Workspaces in Terraform Cloud/Enterprise

To test the role assumption in Terraform Cloud/Enterprise, we need to inform our Terraform workspace with the ARN of the
IAM role.

On the workspace(s), set the following variables as _environment_ variables:
    - `TFC_AWS_PROVIDER_AUTH` should be set to `true`
    - `TFC_AWS_RUN_ROLE_ARN` should be set to the ARN of the IAM role to assume.

Then, use the following sample code in a workspace to demonstrate that it is correctly assuming the role and
authenticating to AWS:

```terraform
provider aws {
 region = "us-east-1"
}

data aws_caller_identity default {}

output arn {
 value = data.aws_caller_identity.default.arn
}
```

The `arn` output should show the ARN of the IAM role.

## Additional Documentation

Here are some links to additional documentation for understanding how best to configure this and how it all works:

 - Terraform Docs: [Dynamic Credentials with the AWS Provider](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration)
 - AWS Blog: [Simplify and Secure Terraform Workloads on AWS with Dynamic Provider Credentials](https://aws.amazon.com/blogs/apn/simplify-and-secure-terraform-workflows-on-aws-with-dynamic-provider-credentials/)


## License

Licensed at your discretion under either:

 - [Apache Software License, Version 2.0](./LICENSE-APACHE)
 - [MIT License](./LICENSE-MIT)


 [build]:      https://github.com/naftulikay/terraform-aws-tfcloud-oidc-iam/actions/workflows/terraform.yml
 [build.svg]:  https://github.com/naftulikay/terraform-aws-tfcloud-oidc-iam/actions/workflows/terraform.yml/badge.svg
 [module]:     https://registry.terraform.io/modules/naftulikay/tfcloud-oidc-iam/aws/latest
 [module.svg]: https://img.shields.io/badge/terraform-module-purple
 [datadog-blog]: https://securitylabs.datadoghq.com/articles/exploring-github-to-aws-keyless-authentication-flaws/
