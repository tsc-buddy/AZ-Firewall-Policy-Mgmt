# Option 1: HCL Variable-Based Configuration

Defines all firewall rules directly as Terraform variables in `terraform.tfvars`. Suitable for small, stable rule sets where the whole team is comfortable with HCL.

## Files

| File | Purpose |
|------|---------|
| `main.tf` | Firewall policy and rule collection group resources |
| `variables.tf` | Variable type definitions |
| `terraform.tf` | Provider and version constraints |
| `terraform.tfvars` | All rule definitions |

## Deploy

```powershell
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

Set your subscription ID in `terraform.tf` before deploying.

## Adding Rules

Add rule collection groups directly in `terraform.tfvars` under the `firewall_rule_collection_groups` variable:

```hcl
firewall_rule_collection_groups = {
  my_app = {
    priority = 4000
    network_rule_collections = [{
      action   = "Allow"
      name     = "MyAppRules"
      priority = 500
      rules = [
        {
          name              = "AppServer"
          source_addresses  = ["10.0.0.0/24"]
          destination_fqdns = ["app.example.com"]
          protocols         = ["TCP"]
          destination_ports = ["443"]
        }
      ]
    }]
  }
}
```

## Trade-offs

**Pros:** Full Terraform type validation, IDE autocomplete, no external dependencies.

**Cons:** Verbose for large rule sets, requires Terraform knowledge to maintain, not well suited to frequent rule changes or environment-specific variations.
