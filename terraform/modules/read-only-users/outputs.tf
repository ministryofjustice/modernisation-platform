output "user_passwords" {
  value = {
    for user in module.iam_user :
    user.this_iam_user_name => user.this_iam_user_login_profile_encrypted_password
    if length(user.pgp_key) > 0
  }
  description = "Map of users and PGP-encrypted passwords, e.g. { bob: 'abcdefg123456' }"
}
