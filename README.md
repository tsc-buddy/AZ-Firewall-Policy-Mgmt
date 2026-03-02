# Azure Firewall Policy — Configuration Samples

This repository contains three sample approaches for managing Azure Firewall Policy rules with Terraform. Each targets a different operational model and team preference.

## Option Comparison

| Option | Approach | Best For | Complexity | Maintainability |
|--------|----------|----------|------------|-----------------|
| Option 1 | HCL Variables | Small, static rule sets | High | Low |
| Option 2 | YAML Files | Most scenarios | Low | High |
| Option 3 | tfvars-driven templates | Standardised, repeatable patterns | Medium | Medium |

## Option 1 — Variable-based Configuration

Rules are defined directly as Terraform variable values in `terraform.tfvars`. All rule structure is expressed in HCL.

Works well for small, relatively static rule sets where the team is comfortable with Terraform. Becomes difficult to manage as rule counts grow.

```powershell
cd policySamples/optionOne
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Option 2 — YAML Configuration

Rules are maintained in YAML files, parsed at plan time via Terraform's `yamldecode`. Infrastructure engineers own the Terraform; security teams can manage rules without touching HCL.

Supports separate YAML files per environment and includes a PowerShell validation script to catch errors before a plan.

```powershell
cd policySamples/optionTwo

# Optional pre-flight validation
.\validate-firewall-rules.ps1 -YamlFile "firewall_rules.yaml"

terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

# Environment-specific
terraform apply -var-file="terraform_nonprod.tfvars"
terraform apply -var-file="terraform_prod.tfvars"
```

## Option 3 — tfvars-driven Templates

Rules and rule collection groups are defined entirely in `firewall_rules.tfvars`. Network segments are abstracted into IP Groups, referenced by key in rule definitions rather than by CIDR. Stamps (customer or environment segments) are declared once and resolved to Azure IP Group IDs at plan time.

Good fit for multi-tenant or multi-segment hub networks where the same rule patterns apply across multiple environments.

```powershell
cd policySamples/optionThree
terraform init
terraform plan -var-file="terraform.tfvars" -var-file="firewall_rules.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="firewall_rules.tfvars"
```

## Repository Structure

```
policySamples/
├── optionOne/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── README.md
├── optionTwo/
│   ├── main.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── terraform.tfvars
│   ├── terraform_nonprod.tfvars
│   ├── terraform_prod.tfvars
│   ├── firewall_rules.yaml
│   ├── firewall_rules_nonprod.yaml
│   ├── firewall_rules_prod.yaml
│   ├── validate-firewall-rules.ps1
│   └── README.md
└── optionThree/
    ├── main.tf
    ├── variables.tf
    ├── locals.tf
    ├── terraform.tfvars
    ├── firewall_rules.tfvars
    └── README.md
```

## Prerequisites

- Terraform >= 1.9.0
- An Azure subscription
- Set `subscription_id` in the relevant `terraform.tfvars` before deploying

All samples use [Azure Verified Modules (AVM)](https://aka.ms/avm) for the Firewall Policy resource.
