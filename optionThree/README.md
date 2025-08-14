# Option 3A: Direct Rule Declaration

This approach uses direct rule declarations in `terraform.tfvars` for maximum visibility and easy troubleshooting, while maintaining Terraform type safety and structure.

## 🎯 **When to Choose Option 3A**

**✅ Choose Option 3A if you want:**
- **Maximum visibility** - See all firewall rules in one place
- **Easy troubleshooting** - No hidden templates or complex logic
- **Terraform benefits** - Type safety, validation, and infrastructure as code
- **Single source of truth** - All rule definitions in terraform.tfvars
- **No template complexity** - Direct rule declarations without abstractions

**❌ Don't choose Option 3A if you:**
- Prefer YAML syntax over HCL (choose Option 2 instead)
- Want pre-built rule templates (original Option 3 with templates)
- Have team members unfamiliar with Terraform HCL syntax
- Need environment-specific rule variations (Option 2 is better)

## 📁 **File Structure**

```
optionThree/
├── main.tf              # Terraform resources and modules
├── variables.tf         # Variable type definitions  
├── terraform.tf        # Provider and version requirements
├── terraform.tfvars    # 🏆 ALL RULES DECLARED HERE
└── README.md           # This documentation
```

**Key Point**: Unlike other options, there are **no hidden templates or complex logic** - everything is declared directly in `terraform.tfvars`.

## 🚀 **Quick Start**

### 1. **Set Your Azure Subscription**
Edit `terraform.tf` and add your subscription ID:
```hcl
provider "azurerm" {
  features {}
  subscription_id = "your-azure-subscription-id-here"
}
```

### 2. **Review and Customize Rules**
Open `terraform.tfvars` and modify the firewall rules for your environment:
- Adjust source subnets to match your network
- Add/remove rules as needed
- Modify priorities if required

### 3. **Deploy**
```powershell
# Initialize Terraform
terraform init

# Preview what will be created
terraform plan -var-file="terraform.tfvars"

# Deploy the firewall policy
terraform apply -var-file="terraform.tfvars"
```

## 📋 **Rule Structure Explained**

### **Top-Level Structure**
```hcl
firewall_rules = {
  rule_collection_name = {
    priority                = number        # Rule collection group priority
    source_subnet          = "CIDR"        # Source network for all rules
    network_collections    = [...]         # Layer 4 network rules
    application_collections = [...]        # Layer 7 application rules
  }
}
```

### **Network Rule Collections**
Used for Layer 4 filtering (IP, ports, protocols):
```hcl
network_collections = [
  {
    action   = "Allow"          # "Allow" or "Deny"
    name     = "CollectionName"
    priority = 500             # Priority within the group
    rules = [
      {
        name              = "Rule Name"
        destination_fqdns = ["example.com"]           # OR
        destination_addresses = ["10.0.0.0/24", "AzureDNS"]  # IP/Service Tags
        protocols         = ["TCP", "UDP"]
        destination_ports = ["443", "80"]
      }
    ]
  }
]
```

### **Application Rule Collections**
Used for Layer 7 filtering (HTTP/HTTPS with FQDN inspection):
```hcl
application_collections = [
  {
    action   = "Allow"
    name     = "ApplicationRules"
    priority = 600
    rules = [
      {
        name              = "HTTPS Traffic"
        destination_fqdns = ["*.microsoft.com"]       # OR
        destination_fqdn_tags = ["WindowsUpdate"]     # Azure service tags
        protocols = [
          {
            port = 443
            type = "Https"      # "Http" or "Https"
          }
        ]
      }
    ]
  }
]
```

## 🛠 **Common Configuration Tasks**

### **Adding a New Rule to Existing Collection**

To add a rule to the `avd` rule collection group:

```hcl
avd = {
  priority      = 1000
  source_subnet = "10.100.0.0/24"
  network_collections = [
    {
      action   = "Allow"
      name     = "AVDCoreNetworkRules"
      priority = 500
      rules = [
        # ... existing core rules ...
        
        # Add your new core rule here
        {
          name              = "Custom AVD Service"
          destination_fqdns = ["myavd.company.com"]
          protocols         = ["TCP"]
          destination_ports = ["8080"]
        }
      ]
    },
    {
      action   = "Allow"
      name     = "AVDOptionalNetworkRules"
      priority = 510
      rules = [
        # ... existing optional rules ...
        
        # Add your new optional rule here
        {
          name              = "Custom Optional Service"
          destination_fqdns = ["optional.company.com"]
          protocols         = ["TCP"]
          destination_ports = ["9090"]
        }
      ]
    }
  ]
  # ... application_collections ...
}
```
```

### **Creating a New Rule Collection Group**

Add a completely new rule collection group:

```hcl
firewall_rules = {
  # ... existing collections ...
  
  # New custom collection
  database_access = {
    priority      = 2500
    source_subnet = "10.200.0.0/24"
    network_collections = [
      {
        action   = "Allow"
        name     = "DatabaseRules"
        priority = 500
        rules = [
          {
            name              = "PostgreSQL"
            destination_fqdns = ["db1.company.com", "db2.company.com"]
            protocols         = ["TCP"]
            destination_ports = ["5432"]
          },
          {
            name              = "Redis Cache"
            destination_addresses = ["10.50.0.10"]
            protocols         = ["TCP"]
            destination_ports = ["6379"]
          }
        ]
      }
    ]
    application_collections = []  # Required even if empty
  }
}
```

### **Environment-Specific Configurations**

For different environments, create separate `.tfvars` files:

**terraform-dev.tfvars:**
```hcl
firewall_policy_name = "azfw-policy-dev"
resource_group_name  = "azfw-rg-dev"

firewall_rules = {
  avd_core = {
    priority      = 1000
    source_subnet = "10.100.0.0/16"  # Broader range for dev
    # ... rules
  }
}
```

**terraform-prod.tfvars:**
```hcl
firewall_policy_name = "azfw-policy-prod"
resource_group_name  = "azfw-rg-prod"

firewall_rules = {
  avd_core = {
    priority      = 1000
    source_subnet = "10.100.0.0/24"  # Restricted range for prod
    # ... rules
  }
}
```

Deploy with:
```powershell
terraform plan -var-file="terraform-dev.tfvars"    # For development
terraform plan -var-file="terraform-prod.tfvars"   # For production
```

## 🔍 **Troubleshooting & Validation**

### **Preview Rules Before Deployment**
```powershell
terraform plan -var-file="terraform.tfvars"
```
This shows exactly which rules will be created - no hidden templates!

### **Validate Configuration Syntax**
```powershell
terraform validate
```

### **Common Issues**

**Issue**: `subscription_id could not be determined`
**Solution**: Set your subscription ID in `terraform.tf`

**Issue**: Rules not appearing as expected
**Solution**: Check the terraform plan output - all rules are clearly visible

**Issue**: Syntax errors in terraform.tfvars
**Solution**: Use terraform validate to check HCL syntax

### **Rule Priority Guidelines**
- **1000-1999**: Core services (AVD, AD, DNS)
- **2000-2999**: Business applications (M365, custom apps)
- **3000-3999**: Internet and general access
- **4000+**: Custom or temporary rules

Lower numbers = higher priority (processed first)

## 📊 **Built-in Rule Collections**

The default configuration includes these rule collection groups:

### **AVD (Priority 1000)**
Azure Virtual Desktop connectivity with both core and optional rules:

**Core Network Rules (Priority 500):**
- Microsoft login services
- AVD service endpoints  
- DNS resolution
- KMS activation

**Optional Network Rules (Priority 510):**
- Time synchronization
- Extended login services

**Optional Application Rules (Priority 600):**
- Windows updates
- Diagnostic services
- Extended Microsoft services

### **M365 (Priority 2000)**
Microsoft 365 connectivity:
- Office 365 service endpoints
- Required M365 traffic

### **Internet (Priority 3000)**
General internet access:
- HTTP/HTTPS to any destination
- Use with caution in production

## ⚙️ **Advanced Configuration**

### **Using Azure Service Tags**
```hcl
{
  name = "Azure Services"
  destination_addresses = [
    "AzureDNS",
    "AzureActiveDirectory", 
    "WindowsVirtualDesktop"
  ]
  protocols = ["TCP"]
  destination_ports = ["443"]
}
```

### **IP Groups Integration**
```hcl
{
  name = "Corporate Networks"
  destination_addresses = ["10.0.0.0/8"]  # Large CIDR blocks
  protocols = ["TCP"]
  destination_ports = ["443", "80"]
}
```

### **Wildcard FQDN Rules**
```hcl
{
  name = "Microsoft Domains"
  destination_fqdns = ["*.microsoft.com", "*.office.com"]
  protocols = ["TCP"]
  destination_ports = ["443"]
}
```

## 🛡️ **Security Best Practices**

1. **Principle of Least Privilege**: Only allow necessary traffic
2. **Specific Source Networks**: Avoid using `0.0.0.0/0` as source
3. **Limited Destination Ports**: Specify exact ports, avoid ranges
4. **Regular Review**: Periodically audit rules in terraform.tfvars
5. **Version Control**: Track all changes through Git
6. **Environment Separation**: Use different .tfvars for dev/prod

## 🆚 **Comparison with Other Options**

| Feature | Option 3A (Direct) | Option 2 (YAML) | Option 3 (Templates) |
|---------|-------------------|------------------|---------------------|
| **Visibility** | ✅ All rules in one file | ✅ Rules in YAML files | ❌ Hidden in templates |
| **Syntax** | HCL/Terraform | YAML | HCL/Terraform |
| **Learning Curve** | Medium | Low | High |
| **Troubleshooting** | ✅ Easy | ✅ Easy | ❌ Complex |
| **Type Safety** | ✅ Full validation | ⚠️ Limited | ✅ Full validation |
| **Templates** | ❌ None | ❌ None | ✅ Reusable templates |

## 📝 **Migration from Other Options**

### **From Option 3 (Templates)**
Your existing rule structure is similar - just move the rule definitions from `locals.tf` into `terraform.tfvars` under the `firewall_rules` variable.

### **From Option 2 (YAML)**
Convert YAML structure to HCL format. The rule logic is the same, just different syntax.

### **From Option 1 (Variables)**
Simplify your complex variable structure into the direct rule declarations shown in this README.

---

## 📞 **Support**

- Review the terraform plan output to see exactly what will be deployed
- All rule definitions are in terraform.tfvars - no hidden configuration
- Use `terraform validate` to check syntax before applying changes
