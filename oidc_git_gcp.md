
# GitHub OIDC Integration with GCP Workload Identity Federation

This guide shows how to configure **GitHub Actions OIDC authentication** with **Google Cloud Workload Identity Federation (WIF)** using only **CLI commands**.

> ✅ No service account keys
> ✅ Short-lived credentials
> ✅ Secure and production-ready

This document covers setup and including:
- Workload Identity Pool
- OIDC Provider (GitHub)
- Service Account
- Required IAM permissions

---

## Prerequisites

- Google Cloud project
- `gcloud` CLI installed and authenticated
- GitHub repository access

Set your project variables:

```bash
export PROJECT_ID=""
export PROJECT_NUMBER=""
export REGION="global"
export GITHUB_REPO=""
export WIF_POOL="github-wif-pool"
export WIF_PROVIDER="githubwif"
export SA_NAME="git-wif-sa"

```

----------

## Step 1 — Create Workload Identity Federation for GitHub

### 1.1 Create Workload Identity Pool

```bash
gcloud iam workload-identity-pools create ${WIF_POOL} \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --display-name="GitHub Actions WIF Pool"

```

----------

### 1.2 Create OIDC Provider (GitHub)

> ⚠️ `--attribute-condition` is **mandatory**
> Only the specified GitHub repository is allowed to authenticate.

```bash
gcloud iam workload-identity-pools providers create-oidc ${WIF_PROVIDER} \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --workload-identity-pool="${WIF_POOL}" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor" \
  --attribute-condition="attribute.repository == '${GITHUB_REPO}'"

```

✅ This establishes trust between **GitHub Actions** and **GCP**.

----------

## Step 1.3 — Create Service Account

```bash
gcloud iam service-accounts create ${SA_NAME} \
  --project="${PROJECT_ID}" \
  --display-name="GitHub Actions WIF Service Account"

```

Service account email:

```text
${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

```
----------
## Step 1.4 — Allow GitHub OIDC to Impersonate the Service Account

```bash
gcloud iam service-accounts add-iam-policy-binding \
  ${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL}/attribute.repository=${GITHUB_REPO}"

```

🔐 This is the **critical binding** that enables GitHub Actions authentication.

----------

## Step 1.5 — Grant Project Permissions to the Service Account



```bash
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/editor"

```

⚠️ **Warning**:
`roles/editor` is **Change as per requirement**.


----------

## Verification Commands

 ### **Mandatory Check**

 ```bash
  gcloud iam service-accounts get-iam-policy \
  ${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

 'You shoud see': role: roles/iam.workloadIdentityUser
  members:
  - principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL}/attribute.repository=${GITHUB_REPO}

❌ If this is missing, GitHub Actions **will not authenticate**.
```

### Check Workload Identity Pool

```bash
gcloud iam workload-identity-pools list \
  --project="${PROJECT_ID}" \
  --location="${REGION}"

'Expected Result' : github-wif-pool
```

### Check Provider

```bash
gcloud iam workload-identity-pools providers list \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --workload-identity-pool="${WIF_POOL}"

  'Expectd Result': githubwif

```

### Check Service Account

```bash
gcloud iam service-accounts list \
  --project="${PROJECT_ID}" \
  --filter="email:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

'Expected result': git-wif-sa@{project-id}.iam.gserviceaccount.com
```

### Check Service Account Permission

```bash
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --format="table(bindings.role)"

  'Expected result ': "roles/editor"
  ```
