data "tls_certificate" "apps_tools_eks" {
  url = local.environment_configuration.apps_tools_eks_oidc_url
}

resource "aws_iam_openid_connect_provider" "apps_tools_eks" {
  url             = local.environment_configuration.apps_tools_eks_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.apps_tools_eks.certificates[0].sha1_fingerprint]
}
