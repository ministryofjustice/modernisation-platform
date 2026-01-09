# 39. AWS CloudTrail Multi-Region and Organization Trail Implementation

Date: 2026-01-09

## Status

✅ Accepted

## Context

- Currently, there are 17 regions in the root account that are disabled by default.
- Current CloudTrail in MP covers **all enabled regions** through a **multi-region trail**, including future regions when they are enabled.
- Other OUs may have varying CloudTrail configurations, some may not want organisation-wide enforcement.
- Enterprise best practice recommends an **Organisation trail** in the root account to ensure:  
  - All accounts and regions are automatically logged  
  - Centralised logging for auditing and compliance

## Options

#### 1 – Do nothing in MP
- Keep the current **multi-region trail** enabled in MP.  
- Logs from new regions will automatically go to the central bucket.  

##### Pros
- No operational overhead in MP  
- Ensures visibility for MP’s accounts  
- Avoids disruption to baseline deployments  

##### Cons
- Only MP accounts are covered, other OUs may not be audited centrally  

---

#### Option 2 – Enable Organisation-wide trail from root account
- Create an **Organisation trail** with multi-region enabled in the root account.  
- Automatically deploys trails to all accounts in the Organisation and centralises logs.  

##### Pros
- Enterprise-wide coverage and compliance  
- Automated logging for future accounts and regions  
- Prevents member accounts from disabling logging  

##### Cons
- Requires coordination with other OUs  
- Some teams may not want organisation-wide changes implemented at this stage   

---

## Decision

- **MP OU will continue using its existing multi-region trail.**  
  - No action is required on our side.  
  - Logs from currently enabled regions and any future-enabled regions will automatically be sent to the **core-logging central bucket**.  
- **Organisation-wide trail in the root account is recommended for enterprise compliance**, but it will not be implemented immediately due to:  
  - Some teams outside MP have **opted not to enable organisation-wide trails** at this stage  
  - MP’s current multi-region trail already ensures full logging for MP’s accounts