# cloud-run-automation

## Trying Cloud Run Service module

### 1: Connect repo to shared project

### 2: Run Terraform for shared environment

### 3: Run Terraform for staging environment

This is going to deploy a Cloud Run service that's running the default demo image.

### 4: Build a container and push it to AR in the shared project

### 5: Update Terraform shared to include your new image
With no revision B specified, it's going to deploy the specified container as a new revision. If you give it a `primary_revision_traffic_percent` it won't matter. Giving it a `revision_b_name` will let you split traffic. 

Feature Request: default it to automatically use the last revision as an automatic revision_b. Could not figure that out but you could do it by using the `last_revision` output from the module as a variable replacement.  

### 6: Try it with a second revision

## Incorporating it in a automated pipeline thing

### Needed:
  - Build trigger that will go off when Terraform changes. It will run Terraform apply. If a new image URL is provided it will roll out the revision 25% at a time. It will use the `latest_revision` output retrieved at the beginning of the run for `TF_VAR_revision_b_name`.  

  