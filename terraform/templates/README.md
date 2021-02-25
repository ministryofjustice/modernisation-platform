# Terraform Templates

This directory contains Terraform `.tf` files that are copied to new environment directories in [environments](../environments). They configure:

- Terraform backends to use our central S3 storage
- sensible local variables, such as application name, and whether the environment is a production environment
- providers for access to the environment and Modernisation Platform for shared resources (e.g. account IDs)
