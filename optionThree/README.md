# Option 3: Template-Based Configuration

This approach uses predefined rule templates and combines them based on configuration variables for standardized deployments.

## 📁 Files

- `main.tf` - Main Terraform configuration using templates
- `variables.tf` - Template control variables
- `locals.tf` - Rule templates and composition logic
- `terraform.tfvars` - Template selection and network configuration

## 🚀 How to Deploy

```powershell
# Navigate to option directory
cd optionThree

# Initialize and deploy
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## ✅ Pros

- **Templates**: Reusable, standardized rule definitions
- **Network Abstraction**: Centralized subnet management
- **Selective**: Easy to enable/disable rule groups
- **Consistency**: Enforced rule structure across environments

## ❌ Cons

- **Template Editing**: Adding new rules requires modifying locals
- **Flexibility**: Limited to predefined template combinations  
- **Learning Curve**: Must understand template structure
- **Custom Rules**: Difficult to add one-off rules

## 🎯 Best For

- Standardized, repeatable rule patterns
- Multi-environment deployments with consistent rules
- Network segment abstraction requirements
- Teams that prefer compositional over declarative approach

## 📝 Configuration

### Enable/Disable Rule Sets

```hcl
# In terraform.tfvars
enabled_rule_sets = ["avd_core", "avd_optional", "m365", "internet"]
```

### Network Segments

```hcl
# In terraform.tfvars  
network_segments = {
  avd_subnet     = "10.100.0.0/24"
  general_subnet = "10.0.0.0/24"
  dmz_subnet     = "10.200.0.0/24"
}
```

### Adding New Templates

To add new rule templates, modify the `rule_templates` in `locals.tf`:

```hcl
# In locals.tf
rule_templates = {
  # Existing templates...
  
  custom_app_rules = [
    {
      name              = "Database Access"
      destination_fqdns = ["myapp.database.com"]
      protocols         = ["TCP"]
      destination_ports = ["3306"]
    }
  ]
}
```

Then add the template configuration:

```hcl
# In locals.tf
rule_collection_configs = {
  # Existing configs...
  
  custom_app = {
    network_collections = [{
      action        = "Allow"
      name          = "CustomAppRules"
      priority      = 500
      rules         = local.rule_templates.custom_app_rules
      source_subnet = var.network_segments.general_subnet
    }]
  }
}
```
