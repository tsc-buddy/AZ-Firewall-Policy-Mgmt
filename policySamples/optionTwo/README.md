# Option 2: YAML-Based Configuration

Defines firewall rules in external YAML files. Infrastructure engineers manage Terraform; security teams manage rules in human-readable YAML without needing Terraform knowledge.

## Files

| File | Purpose |
|------|---------|
| `main.tf` | Firewall policy resources with YAML parsing |
| `variables.tf` | Variable definitions |
| `locals.tf` | YAML loading and processing logic |
| `terraform.tfvars` | Infrastructure configuration |
| `terraform_nonprod.tfvars` | Non-production deployment values |
| `terraform_prod.tfvars` | Production deployment values |
| `firewall_rules.yaml` | Default rule set |
| `firewall_rules_nonprod.yaml` | Non-production rules |
| `firewall_rules_prod.yaml` | Production rules |
| `validate-firewall-rules.ps1` | Pre-deployment YAML validation |

## Deploy

```powershell
# Validate YAML before deploying (optional)
.\validate-firewall-rules.ps1 -YamlFile "firewall_rules.yaml"

# Default deployment
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

# Environment-specific deployments
terraform apply -var-file="terraform_nonprod.tfvars"
terraform apply -var-file="terraform_prod.tfvars"
```

Set your subscription ID in `terraform.tf` before deploying.

## Trade-offs

**Pros:** YAML is easy to read and modify, environment-specific rule files, pre-deployment validation script, no Terraform knowledge required to manage rules.

**Cons:** YAML parsing adds a layer of indirection, less Terraform type safety than HCL options, YAML syntax errors surface at plan time rather than at write time.
