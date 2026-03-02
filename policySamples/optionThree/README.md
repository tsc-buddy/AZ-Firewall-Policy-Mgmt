# Option 3: Direct tfvars Declaration with IP Groups

Declares all firewall rules in a dedicated `firewall_rules.tfvars` file, separate from infrastructure configuration. Uses Azure IP Groups as a single source of truth for network segment CIDRs, allowing rules to reference logical group names rather than raw CIDR blocks.

## Files

| File | Purpose |
|------|---------|
| `main.tf` | Firewall policy, IP groups, and rule collection group resources |
| `variables.tf` | Variable type definitions including `stamps` and `firewall_rules` |
| `locals.tf` | IP group ID lookup map resolved from stamp CIDRs |
| `terraform.tf` | Provider and version constraints |
| `terraform.tfvars` | Infrastructure values and stamp CIDR definitions |
| `firewall_rules.tfvars` | All rule collection groups and rules |

## Deploy

```powershell
terraform init
terraform plan -var-file="terraform.tfvars" -var-file="firewall_rules.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="firewall_rules.tfvars"
```

Set your subscription ID in `terraform.tfvars` before deploying.

## Key Concepts

### Stamps

A `stamp` is a named network environment. Each stamp defines CIDRs for its workload and identity subnets:

```hcl
stamps = {
  prod = {
    test_address_prefix     = "10.10.0.0/24"
    preprod_address_prefix  = "10.11.0.0/24"
    prod_address_prefix     = "10.12.0.0/24"
    identity_address_prefix = "10.10.100.0/24"
  }
}
```

Terraform creates one Azure IP Group per environment per stamp (`<stamp>-test`, `<stamp>-preprod`, `<stamp>-prod`, `<stamp>-identity`). These keys are the only identifiers you need in rule definitions.

### Referencing IP Groups in Rules

Rules use `source_ip_group_keys` and `destination_ip_group_keys` instead of raw IP addresses:

```hcl
{
  name                      = "prod-to-identity"
  source_ip_group_keys      = ["prod-prod"]
  destination_ip_group_keys = ["prod-identity"]
  protocols                 = ["TCP"]
  destination_ports         = ["443", "389", "636"]
}
```

Terraform resolves these keys to Azure resource IDs at plan time. CIDRs only need to be updated in `terraform.tfvars` — rules never need to change.

## Rule Structure

```hcl
firewall_rules = {
  rcg_name = {
    priority = 1000

    network_collections = [
      {
        name     = "CollectionName"
        priority = 100
        action   = "Allow"
        rules = [
          {
            name                      = "RuleName"
            source_ip_group_keys      = ["stamp-env"]        # optional
            source_addresses          = ["10.0.0.0/24"]      # optional
            destination_ip_group_keys = ["stamp-env"]        # optional
            destination_addresses     = ["AzureActiveDirectory"] # optional, supports service tags
            destination_fqdns         = ["*.microsoft.com"]  # optional
            protocols                 = ["TCP"]
            destination_ports         = ["443"]
          }
        ]
      }
    ]

    application_collections = [
      {
        name     = "CollectionName"
        priority = 200            # must be unique across all collection types in the RCG
        action   = "Allow"
        rules = [
          {
            name                 = "RuleName"
            source_ip_group_keys = ["stamp-env"]
            destination_fqdns    = ["*.example.com"]
            destination_fqdn_tags = ["WindowsUpdate"]       # optional, AzFW FQDN tags
            protocols = [
              { port = 443, type = "Https" }
            ]
          }
        ]
      }
    ]

    nat_collections = [
      {
        name     = "CollectionName"
        priority = 300
        action   = "Dnat"
        rules = [
          {
            name                = "RuleName"
            source_addresses    = ["*"]
            destination_address = "20.0.0.1"    # firewall public IP
            destination_ports   = ["443"]
            translated_address  = "10.0.1.10"
            translated_port     = "443"
            protocols           = ["TCP"]
          }
        ]
      }
    ]
  }
}
```

## Priority Rules

Priorities must be unique across **all** collection types (network, application, NAT) within a single Rule Collection Group. Use distinct ranges to avoid conflicts:

| Range | Suggested use |
|-------|---------------|
| 100-199 | Network collections |
| 200-299 | Additional network collections |
| 300-499 | Application collections |
| 500-599 | NAT collections |

Rule Collection Group priorities follow a similar pattern at the policy level:

| Range | Suggested use |
|-------|---------------|
| 1000-1999 | Infrastructure / east-west / identity |
| 2000-2999 | Workload / platform services |
| 3000-3999 | Workload egress |
| 4000-4999 | DNAT / inbound |

## Service Tags

Use Azure service tags in `destination_addresses` for network rules to avoid maintaining large IP lists:

```hcl
destination_addresses = ["WindowsVirtualDesktop"]
destination_addresses = ["AzureActiveDirectory"]
destination_addresses = ["AzureMonitor"]
```

## Trade-offs

**Pros:** Clean separation of infrastructure and rules, IP Groups as single source of truth for CIDRs, rules reference logical names rather than IP addresses, full Terraform type validation, scales well for stamp/hub-spoke architectures.

**Cons:** More initial setup than Options 1 or 2, requires understanding of the stamps pattern, HCL syntax in tfvars (not YAML).
