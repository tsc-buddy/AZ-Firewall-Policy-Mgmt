# Azure Firewall Policy Configuration Options

This repository provides three different approaches to parameterize Azure Firewall Policy rules and rule collections, each optimized for different use cases and team structures.

## 📊 **Option Comparison**

| Option | Approach | Best For | Complexity | Maintainability | Scalability |
|--------|----------|----------|------------|-----------------|-------------|
| **Option 1** | Complex Variables | Small teams, < 50 rules | High | Low | Average |
| **Option 2** ⭐ | YAML Files | Most scenarios | Low | High | Excellent |
| **Option 3** | Rule Templates | Standardized patterns | Medium | Medium | Great |

## 🚀 **Quick Start Guides**

### **Option 1 (Variable-based Configuration)**

```powershell
# Navigate to Option 1
cd optionOne

# Deploy with complex Terraform variables
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### **Option 2 (YAML Configuration)** ⭐ **RECOMMENDED**

```powershell
# Navigate to Option 2
cd optionTwo

# Validate configuration (optional)
.\validate-firewall-rules.ps1 -YamlFile "firewall_rules.yaml"

# Deploy with main configuration
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

# Environment-specific deployments
terraform apply -var-file="terraform_nonprod.tfvars"  # Non-production
terraform apply -var-file="terraform_prod.tfvars"    # Production
```

### **Option 3 (Template-based Configuration)**

```powershell
# Navigate to Option 3
cd optionThree

# Deploy with rule templates
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## 🎯 **Which Option Should I Choose?**

### **Choose Option 2 (YAML)** ⭐ **RECOMMENDED** if you want:
- ✅ Easy rule management for security teams
- ✅ Environment-specific configurations (nonprod/prod)
- ✅ Clean separation of rules and infrastructure code
- ✅ Best scalability for growing rule sets
- ✅ Human-readable, version-control friendly configuration

### **Choose Option 1 (Variables)** if you have:
- Small, unchanging rule sets (< 50 rules)
- Team consisting entirely of Terraform experts
- Need for maximum type safety and validation
- Preference for pure Terraform approach

### **Choose Option 3 (Templates)** if you need:
- Standardized, repeatable rule patterns
- Network segment abstraction
- Compositional approach to rule management
- Selective enabling/disabling of rule groups

## 📖 **Getting Started**

1. **Choose** your preferred option using the comparison above
2. **Navigate** to your chosen option directory
3. **Read** the option-specific README.md for detailed instructions
4. **Customize** the configuration files for your environment
5. **Deploy** using the provided commands

## 📁 **Repository Structure**

```
factory/
├── optionOne/                      # Variable-based configuration
│   ├── main.tf                     # Terraform configuration with for_each
│   ├── variables.tf                # Complex variable definitions
│   ├── terraform.tfvars            # Rule configuration in variables
│   └── README.md                   # Option 1 detailed guide
├── optionTwo/                      # 🏆 YAML-based configuration (RECOMMENDED)
│   ├── main.tf                     # YAML parsing implementation
│   ├── variables.tf                # Simple variables
│   ├── locals.tf                   # YAML loading logic
│   ├── terraform.tfvars            # Basic deployment values
│   ├── terraform_nonprod.tfvars    # Non-production environment
│   ├── terraform_prod.tfvars       # Production environment
│   ├── firewall_rules.yaml         # Main rule configuration
│   ├── firewall_rules_nonprod.yaml # Non-production rules
│   ├── firewall_rules_prod.yaml    # Production rules
│   ├── validate-firewall-rules.ps1 # Validation script
│   └── README.md                   # Option 2 detailed guide
├── optionThree/                    # Template-based configuration
│   ├── main.tf                     # Template-based implementation
│   ├── variables.tf                # Template control variables
│   ├── locals.tf                   # Rule templates and logic
│   ├── terraform.tfvars            # Template configuration
│   └── README.md                   # Option 3 detailed guide
└── README.md                       # This overview file
```

## 🏆 **Why Option 2 is Recommended**

Option 2 (YAML Configuration) strikes the perfect balance between:
- **Simplicity** - Easy to understand and modify
- **Flexibility** - Environment-specific configurations
- **Maintainability** - Clean separation of concerns
- **Accessibility** - Non-Terraform users can manage rules
- **Scalability** - Handles large rule sets gracefully

For most organizations, Option 2 provides the best long-term solution for managing Azure Firewall policies.

## 🔧 **Common Configuration**

All options deploy to:
- **Location**: Australia East
- **Resource Groups**: `azfwpolicy-rg-option[1-3]`
- **Firewall Policy Names**: `azfw-policy-option[1-3]`
- **AVM Modules**: Uses official Azure Verified Modules

All options deploy to:
- **Location**: Australia East
- **Naming Convention**: `azfw-policy-option[1-3]`
- **AVM Modules**: Uses official Azure Verified Modules
