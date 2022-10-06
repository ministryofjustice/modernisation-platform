# Get Security Hub Findings

This script retrieves Security Hub findings with the severity `CRITICAL` or `HIGH`, for the Security Hub product, across all Modernisation Platform accounts.

Note that Security Hub also accepts findings from Config, Inspector and other services, these should be integrated at a later date.

## Running the script locally as superadmin user 

1. Run the script using AWS vault (or whatever tool you use) to assume a suitable role

`aws-vault exec modernisation-platform-superadmin -- go run main.go`

## Import the csv file

The script creates a csv with with a `|` separator. (This is because the security hub descriptions sometimes contain tabs or commas.)

Import the file into a Google Sheet as follows:

1. File -> Import
1. Upload
1. Drag or browse for `findings.csv`
1. Choose the relevant "Import location"
1. Choose "Separator type" - "Custom"
1. Enter `|` for "Custom separator"
1. Click "Import data"
