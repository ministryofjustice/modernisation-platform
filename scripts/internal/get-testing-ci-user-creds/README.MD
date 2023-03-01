# Running tests locally with the testing-ci user

The `testing-ci` user is used to run tests on the GitHub Actions pipelines.

To run the same tests locally you will need to retrieve the credentials for the testing-ci user and run the tests using those credentials.

1. Run the script using AWS vault (or whatever tool you use) to assume a suitable role

`aws-vault exec modernisation-platform-superadmin -- go run get_testing_creds.go`

2. Copy the output into the terminal that you want to run the tests from.

```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxx
```

3. Run the tests

`go test`
