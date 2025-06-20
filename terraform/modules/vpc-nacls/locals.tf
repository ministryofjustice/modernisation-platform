locals {
  laa_workspaces = [
    "laa-development",
    "laa-test",
    "laa-preproduction",
    "laa-production"
  ]

  subnet_suffixes = ["a", "b", "c"]

  cidr_blocks = {
    "laa-development"   = "13.17.132.44/32"
    "laa-test"          = "13.17.132.45/32"
    "laa-preproduction" = "13.17.132.46/32"
    "laa-production"    = "13.17.132.47/32"
  }

  base_rule_numbers = {
    "laa-development"   = 6010
    "laa-test"          = 6020
    "laa-preproduction" = 6030
    "laa-production"    = 6040
  }

  laa_ssh_acl_rules_by_workspace = {
    for ws in local.laa_workspaces : ws => {
      for idx, suffix in local.subnet_suffixes :
      "subnet_${suffix}_ssh" => {
        cidr_block  = local.cidr_blocks[ws]
        egress      = true
        from_port   = 22
        protocol    = "tcp"
        rule_action = "allow"
        rule_number = local.base_rule_numbers[ws] + idx
        to_port     = 22
      }
    }
  }
}