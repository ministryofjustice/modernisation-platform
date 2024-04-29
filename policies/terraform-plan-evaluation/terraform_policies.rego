package main

import data.terraform.plan_functions
import input.resource_changes

# Protected resources
protected_resources := [
#   "aws_ssm_parameter.modernisation_platform_account_id",
#   "module.shield_response_team_role.aws_iam_role_policy_attachment.custom[0]"
]

# Change maximums
max_additions := 10
max_deletions := 22
max_modifications := 10

# Get different resource change types
# Get all creates
resources_added := plan_functions.get_resources_by_action("create", resource_changes)

# Get all deletes
resources_removed := plan_functions.get_resources_by_action("delete", resource_changes)

# Get all modifies
resource_changed := plan_functions.get_resources_by_action("update", resource_changes)


# Check to see if there are too many changes
warn[msg] {
    count(resources_added) > max_additions
    msg := sprintf("Too many resources added. Only %d resources can be added at a time.", [max_additions])
}

deny[msg] {
    count(resources_removed) > max_deletions
    msg := sprintf("%v resources will be deleted. Only %d resources can be deleted at a time!", [ count(resources_removed), max_deletions])
}

warn[msg] {
    count(resource_changed) > max_modifications
    msg := sprintf("Too many resources updated. Only %d resources can be changed at a time.", [max_modifications])
}

# Check to see if protected resources are being deleted
deny[msg] {
    check_protected := [resources_removed[_].address]
    check_protected[i] == protected_resources[j]
    msg := sprintf("Protected resources are being deleted because `%v` matches `%v`",[check_protected[i], protected_resources[j]])
}

# Check if production resources (or any particular tagged resource) will be destroyed
deny[msg] {
    resource_address := [resources_removed[_].address]
    check_for_prod_tags := [resources_removed[_].change.before.tags["is-production"]]
    check_for_prod_tags != 0
    msg := sprintf("`%v` is a production resource that will be deleted",[resource_address])
}
