resource "aws_ssm_document" "cross-account-single-patching-automation" {
  name          = "cross-account-single-patching-automation"
  document_type = "Automation"

  content = <<DOC
  {
    "outputs": [
        "runPatchBaseline.Output"
    ],
    "description": "Automation document to execute the Command document AWS-RunPatchBaseline",
    "schemaVersion": "0.3",
    "assumeRole": "{{AutomationAssumeRole}}",
    "parameters": {
        "AutomationAssumeRole": {
            "type": "String",
            "description": "(Optional) The ARN of the role that allows Automation to perform the actions on your behalf.",
            "default": "AWS-SSM-AutomationExecutionRole"
        },
        "Operation": {
            "allowedValues": [
                "Scan",
                "Install"
            ],
            "description": "(Required) The update or configuration to perform on the instance. The system checks if patches specified in the patch baseline are installed on the instance. The install operation installs patches missing from the baseline.",
            "type": "String"
        },
        "SnapshotId": {
            "default": "",
            "description": "(Optional) The snapshot ID to use to retrieve a patch baseline snapshot.",
            "type": "String",
            "allowedPattern": "(^$)|^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
        },
        "InstanceId": {
            "description": "(Required) EC2 InstanceId to which we apply the patch-baseline",
            "type": "String"
        },
        "InstallOverrideList": {
            "default": "",
            "description": "(Optional) An https URL or an Amazon S3 path-style URL to the list of patches to be installed. They need to be in a yaml format. This patch installation list overrides the patches specified by the default patch baseline.",
            "type": "String",
            "allowedPattern": "(^$)|^https://.+$|^s3://([^/]+)/(.*?([^/]+))$"
        }
    },
    "mainSteps": [
        {
            "maxAttempts": 3,
            "inputs": {
                "Parameters": {
                    "SnapshotId": "{{SnapshotId}}",
                    "InstallOverrideList": "{{InstallOverrideList}}",
                    "Operation": "{{Operation}}"
                },
                "InstanceIds": [
                    "{{InstanceId}}"
                ],
                "DocumentName": "AWS-RunPatchBaseline"
            },
            "name": "runPatchBaseline",
            "action": "aws:runCommand",
            "timeoutSeconds": 7200,
            "onFailure": "Abort"
        }
    ]
}
DOC
}