---
name: terraform
description: Use when applying Terraform changes. Enforces the plan-then-apply workflow with a saved plan file to ensure deterministic applies.
---

# Terraform Apply Workflow

Always use the two-step plan-then-apply workflow when applying Terraform changes. Never run `terraform apply` directly without a saved plan.

## Required Workflow

### 1. Plan with output file
```bash
terraform plan -out=tfplan
```

This saves the execution plan to a file (`tfplan`), ensuring the exact changes reviewed are what gets applied.

### 2. Apply the saved plan
```bash
terraform apply tfplan
```

This applies only the changes captured in the plan file — no re-evaluation, no surprises.

### 3. Clean up the plan file
```bash
rm tfplan
```

## Rules

- **Never** run `terraform apply -auto-approve` without a saved plan file.
- **Never** run `terraform apply` without first running `terraform plan -out=<file>`.
- **Always** review the plan output before applying.
- If the plan shows unexpected changes, stop and investigate before applying.

## Example

```bash
cd terraform/azure-demo/ai-deployments
terraform plan -out=tfplan
# Review the plan output
terraform apply tfplan
rm tfplan
```
