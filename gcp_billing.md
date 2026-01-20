# GCP Billing Automation: Hard Stop at Budget

This document outlines the architecture and implementation for automatically stopping GCP services when a specific budget threshold is reached.

## 1. Overview
GCP Budgets do not stop services by default. To implement a "Hard Stop," we use a Pub/Sub topic to bridge the Budget alert and a Cloud Function that disables billing for the project.

## 2. Components
- **Budget**: Configured to send notifications to a Pub/Sub topic.
- **Pub/Sub Topic**: `billing-threshold-reached`
- **Cloud Function**: `stop-billing-on-budget` (Python 3.11)
- **IAM Permissions**: The Cloud Function's Service Account must have **Project Billing Manager** site-wide or per-project.

## 3. Implementation Steps

### Step A: Create Pub/Sub Topic
```bash
gcloud pubsub topics create billing-threshold-reached
```

### Step B: Link Budget to Pub/Sub
Update the budget to send messages:
```bash
gcloud billing budgets update [BUDGET_ID] \
    --billing-account=0122C1-D97B63-7B716A \
    --notifications-pubsub-topic=projects/gen-lang-client-0920366707/topics/billing-threshold-reached
```

### Step C: Cloud Function Logic (`main.py`)
```python
import base64
import json
import os
from google.cloud import billing_v1

PROJECT_ID = os.getenv('GCP_PROJECT')
client = billing_v1.CloudBillingClient()

def stop_billing(event, context):
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    data = json.loads(pubsub_message)
    cost_amount = data.get('costAmount')
    budget_amount = data.get('budgetAmount')

    if cost_amount and budget_amount and cost_amount >= budget_amount:
        print(f"Cost {cost_amount} exceeded budget {budget_amount}. Disabling billing for {PROJECT_ID}...")
        
        # This effectively stops all paid services in the project
        client.update_project_billing_info(
            name=f"projects/{PROJECT_ID}",
            project_billing_info={'billing_account_name': ''}
        )
```

## 4. Operational Notes
- **To Reactivate**: You must manually re-link the project to the billing account in the Console.
- **Approving $10 increments**: Increase the Budget threshold to the next $10 level and re-enable billing for the project.

gcloud billing budgets update cab0cd2b-5872-4e4d-82a9-a80d09eceabd     --billing-account=0122C1-D97B63-7B716A     --budget-amount=40USD


python3 ~/top_up_budget.py

## 5. Real-Time Governor (Token-Based)
This additional layer provides sub-minute protection by monitoring actual token usage from logs.

### Components
- **Firestore**: Tracks daily spend state (`usage` collection).
- **Log Sink**: `billing-log-sink` (Captures `aiplatform.googleapis.com` calls).
- **Cloud Function**: `real-time-billing-governor`

### Operational Logic
The governor estimates cost as: `(Total Tokens / 1,000,000) * $1.50`.
If the Firestore `daily_total` reaches **$10.00**, billing is disabled immediately.

### How to Monitor
- **Logs**: View real-time logs in the Console under Cloud Functions > `real-time-billing-governor` > Logs. You will see "Daily total so far: \$X.XXXX".
- **Database**: View the running total in the Firestore Viewer for the document `usage/[YYYY-MM-DD]`.
- **Notifications**: The function sends an email via the standard GCP Error Reporting/Alerting if the "Kill" action is triggered.
