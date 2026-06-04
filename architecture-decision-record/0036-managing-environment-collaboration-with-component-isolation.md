# 36. Managing Environment Collaboration through Component-Based Isolation

Date: 2024-02-01

## Status

✅ Accepted

## Context

The **modernisation platform environments** are structured in a way that makes it challenging for multiple teams to collaborate effectively within a **single account**. The current workaround **requesting a new account** for each team or project has limitations. It adds complexity to account management, increases overhead, and is not always feasible or desirable due to resource constraints or organizational policies.

To address this challenge, we need a more scalable, efficient, and automated solution that supports isolated development environments while maintaining a streamlined account structure.

## Decision

Instead of creating new accounts for each project or team, we will adopt a **component-based isolation** strategy within the existing account structure. The solution involves:

#### Component Definition

Each new component will be defined in the `<application>.json` configuration file. This provides a centralized and consistent approach to managing components.

#### Automated Setup Process

Once a component is added to the `<application>.json`, an **automated process** will trigger the creation of the following within the root directory:

- **Component Subdirectory:**  

    A dedicated subdirectory for each component to organize resources, configurations, and code related to that component.

- **platform_backend.tf:**  

    This Terraform file will create a **separate state** for the component, ensuring isolation of infrastructure resources and preventing state conflicts between components.

- **Workspaces for Existing Environments:**  

    Terraform workspaces will be created for each existing environment (e.g., dev, staging, production) within the component. This ensures environment-specific configurations and deployments remain isolated.
