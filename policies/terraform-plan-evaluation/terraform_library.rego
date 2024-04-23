package terraform.plan_functions

import future.keywords


# Get resources by type
get_resources_by_type(type, resources) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.type = type]
}

# Get resources by action
get_resources_by_action(action, resources) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.change.actions[_] = action]
}

# Get resources by type and action
get_resources_by_type_and_action(type, action, resources) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.type = type; resource.change.actions[_] = action]
}

# Get resource by name
get_resource_by_name(resource_name, resources) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.name = resource_name]
}

# Get resource by type and name
get_resource_by_type_and_name(type, resource_name, resources) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.type = type; resource.name = resource_name]
}