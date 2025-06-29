Here is the updated `README.md` file content that includes your **Terraform setup instructions**, along with a full description of the solution, architecture, and deployment plan.

---

### ✅ `README.md`

```markdown
# 🚀 Azure Cosmos DB Cost Optimization - Serverless Architecture

## 🧩 Problem Statement

We have a serverless architecture in Azure, where billing records are stored in **Azure Cosmos DB**. The system is **read-heavy**, but records older than three months are rarely accessed.

> Over time, Cosmos DB cost has increased significantly. We need a **cost-efficient**, **available**, and **non-disruptive** solution.

---

## ✅ Solution Overview

### 🔄 Archive Rarely Accessed Data

- Archive records older than 3 months to **Azure Blob Storage (Cool Tier)**.
- Use **Azure Data Factory** (ADF) or **Timer Triggered Azure Functions** for scheduled archival.
- Retrieval API remains **unchanged** – fallback to Blob if record isn't in Cosmos DB.

---

## 🏗️ Architecture Diagram

![Architecture](./diagram/architecture.png)

---

## ⚙️ Technologies Used

- Azure Cosmos DB (Serverless)
- Azure Blob Storage
- Azure Function (Python/Node)
- Azure Data Factory
- Azure Terraform for IaC

---

## 📦 Folder Structure

```
.
├── diagram/
│   └── architecture.png
├── scripts/
│   ├── archive_old_records.py
│   └── retrieve_billing_record.js
├── pseudocode/
│   ├── archival_logic.txt
│   └── retrieval_logic.txt
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
└── README.md
```

---

## 💡 Key Benefits

| Feature                  | Achieved |
|--------------------------|----------|
| 💸 Cost Reduction         | ✅        |
| 🔐 No Data Loss           | ✅        |
| 🔄 No Downtime            | ✅        |
| 🔁 No Change to API       | ✅        |
| ⚙️ Easy to Maintain        | ✅        |
| 📉 Uses Azure Native Tools| ✅        |

---

## 🧠 Logic Overview

### Archival Logic (Python)

- Query Cosmos DB for records older than 90 days
- Export to Azure Blob Storage in partitioned folders
- Delete old records from Cosmos DB (after backup)

### Retrieval Logic (Node/JavaScript)

- Attempt read from Cosmos DB
- On miss, compute blob path and fetch from Azure Blob

---

## 🛠️ Infrastructure Deployment (Terraform)

To provision resources via Terraform:

### 📥 Prerequisites

- Terraform installed:
  ```bash
  brew install terraform        # for macOS
  choco install terraform       # for Windows
  ```

- Azure CLI installed:
  ```bash
  az login
  ```

### 🚀 Deployment Steps

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This will provision:
- Azure Resource Group
- Azure Cosmos DB (Serverless)
- Azure Blob Storage
- Azure Function App (Python Runtime)
- Azure Data Factory (Empty Shell)

---

## 🎁 Bonus

- ✅ Fully serverless & low-maintenance
- 📊 Diagram included
- 💬 Clean logic structure
- 🏗️ Terraform IaC for reproducibility

---

## 📩 How to Submit

Push to GitHub and share the link with the HR team. Optional: Record a Loom video walkthrough to explain your architecture.

---

## 📌 Author

**Nipun Yadav**  
Assignment for Symplique Solutions – Azure Engineer Position  
```

---

Let me know if you'd like:
- The `.zip` of Azure Function sample code to upload
- Architecture diagram as an image (I can generate one)
- Pre-written Terraform variable examples for easy editing

I'm ready to help you complete the GitHub repo in the most professional way.