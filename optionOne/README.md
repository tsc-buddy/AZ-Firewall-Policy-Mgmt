# Option 1: Variable-Based Configuration

This approach uses complex Terraform variables to define all firewall rules and rule collections in a structured format.

## 📁 Files

- `main.tf` - Main Terraform configuration with for_each loops
- `variables.tf` - Complex variable definitions with type validation  
- `locals.tf` - Azure regions list
- `terraform.tfvars` - Complete rule configuration in variables

## 🚀 How to Deploy

```powershell
# Navigate to option directory
cd optionOne

# Initialize and deploy
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## ✅ Pros

- **Type Safety**: Full Terraform type validation
- **IntelliSense**: IDE autocomplete support
- **Documentation**: Built-in variable descriptions
- **Native**: Pure Terraform approach

## ❌ Cons

- **Complexity**: Extremely verbose for large rule sets
- **Maintenance**: Requires deep Terraform knowledge
- **Scalability**: Becomes unwieldy with many rules
- **User-Friendly**: Not accessible to non-Terraform users

## 🎯 Best For

- Small, static rule sets (< 50 rules)
- Teams of only Terraform experts
- When type safety is critical
- Simple, single-environment deployments

---

## ⚠️ Required: Azure Subscription ID

Before deploying, edit `terraform.tf` and set the `subscription_id` value in the `provider "azurerm"` block to your Azure Subscription ID.

## 📝 Adding New Rules

To add new rules, modify the `firewall_rule_collection_groups` variable in `terraform.tfvars`:

```hcl
firewall_rule_collection_groups = {
  existing_group = { ... }
  
  # Add new group
  custom_app = {
    priority = 4000
    network_rule_collections = [{
      action   = "Allow"
      name     = "CustomAppRules"
      priority = 500
      rules = [
        {
          name              = "Database Access"
          source_addresses  = ["10.0.0.0/24"]
          destination_fqdns = ["myapp.database.com"]
          protocols         = ["TCP"]
          destination_ports = ["3306"]
        }
      ]
    }]
  }
}
```
