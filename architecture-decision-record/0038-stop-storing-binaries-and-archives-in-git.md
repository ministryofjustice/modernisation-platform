# 38. Stop storing binary and archive files in git

Date: 2025-10-23

## Status

✅ Accepted

## Context

Currently we do not restrict developers from merging binary/archive files into our GitHub repositories, most notably in [modernisation-platform-environments](https://github.com/ministryofjustice/modernisation-platform-environments) which currently contains a number of large `.zip` files.

There are a number of reasons why this is not considered best practice including;

- These file types are often large, which can bloat the repository and slow down cloning and fetching for all users

- Storing such files in git goes against best practices; they are better managed in object storage (e.g. S3 or artifact repositories)

- Binary and archive files cannot be efficiently diffed or merged, making code review and collaboration difficult

## Options

A number of options have been explored as part of issue [#8393](https://github.com/ministryofjustice/modernisation-platform/issues/8393) to mitigate this.

#### 1. Add a number of common binary and archive file extensions to the `.gitignore` file

##### Pros 
    
- Stops inadvertent committing of binary/archive files

##### Cons

- Can be overridden using the git force flag

#### 2. Add a number of common binary and archive file extensions to the `CODEOWNERS` file of the `modernisation-platform-environments`repo requiring approval from the Modernisation Platform Team

##### Pros 
    
- Stops binary/archive files being committed to the repo without prior approval from the MP team

##### Cons

- Files can still be committed in branches so developers may be unaware of the issue until raising a PR
- Files committed in branches will persist in git history until the branch is deleted

#### 3. Add a status check that fails when binary/archive files are detected and comments on PR to warn the author

##### Pros 
    
- Status check failure will raise awareness of the issue with the author and reviewer and suggest alternative approaches

##### Cons

- Failing status checks do not stop merging into `main`, only one approving review is required


## Decision

- Communicate with members giving advance notice of our intention to stop binary/archive files being stored in MP Git repos 
- Suggest members use s3 as the primary mechanism to store these file types (e.g. create s3 bucket and manually upload artifacts, reference s3 locations in code)
- Implement **all three** options listed above to help control these files being added to Git
- Work with members to re-home existing `.zip` files from the repository and update code as required