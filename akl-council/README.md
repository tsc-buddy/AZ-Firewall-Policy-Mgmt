# Hub Network — Azure Firewall Policy

Deploys a hub network with Azure Firewall, Firewall Policy, and IP-Group-based rule management for a multi-stamp environment.

## Infrastructure Deployed

| Resource | Name |
|----------|------|
| Resource Group | `rg-hub-vnet-prod-01` |
| Virtual Network | `vnet-hub-prod-001` |
| Azure Firewall | `afw-hub-prod-001` |
| Firewall Policy | `afw-policy-hub-prod-001` |
| Public IP | `pip-afw-hub-prod-001` |
| IP Groups | `ipg-<stamp>-<test\|preprod\|prod\|identity>` |
| Diagnostic Settings | Log Analytics Workspace |

All resources are deployed to the `newzealandnorth` region.

## Architecture

Traffic from workload VNets across three stamps (aklc, gss, wsl) is routed through this centralised hub firewall. Each stamp has four IP Groups representing its environment tiers:

```
<stamp>-test       → test workload VNet CIDR
<stamp>-preprod    → pre-production workload VNet CIDR
<stamp>-prod       → production workload VNet CIDR
<stamp>-identity   → identity spoke CIDR (domain controllers)
```

No cross-stamp traffic is permitted. East-west rules are scoped per stamp.

## Files

| File | Purpose |
|------|---------|
| `main.tf` | All Azure resources and AVM module calls |
| `variables.tf` | Variable definitions including `stamps` and `firewall_rules` |
| `locals.tf` | Mandatory tags and IP group ID lookup map |
| `terraform.tf` | Provider and version constraints |
| `terraform.tfvars` | Infrastructure values, stamp CIDRs, tags |
| `firewall_rules.tfvars` | All firewall rule collection groups and rules |
| `outputs.tf` | Firewall private/public IPs, resource IDs |

## Deploy

```powershell
terraform init

terraform plan \
  -var-file="terraform.tfvars" \
  -var-file="firewall_rules.tfvars"

terraform apply \
  -var-file="terraform.tfvars" \
  -var-file="firewall_rules.tfvars"
```

## How Stamps and IP Groups Work

Stamp CIDRs are defined once in `terraform.tfvars`:

```hcl
stamps = {
  aklc = {
    test_address_prefix     = "10.10.0.0/24"
    preprod_address_prefix  = "10.11.0.0/24"
    prod_address_prefix     = "10.12.0.0/24"
    identity_address_prefix = "10.10.100.0/24"
  }
  gss = { ... }
  wsl = { ... }
}
```

Terraform creates one Azure IP Group per tier per stamp (12 total). The `locals.tf` lookup map resolves stamp keys to Azure resource IDs at plan time.

Rules in `firewall_rules.tfvars` reference IP groups by key name — CIDRs never appear in rule definitions:

```hcl
{
  name                      = "aklc-Workload-to-Identity-TCP"
  source_ip_group_keys      = ["aklc-test", "aklc-preprod", "aklc-prod"]
  destination_ip_group_keys = ["aklc-identity"]
  protocols                 = ["TCP"]
  destination_ports         = ["389", "636", "3268", "88", "445"]
}
```

To update a CIDR, change `terraform.tfvars` only — all rules follow automatically.

## Firewall Rules

Rules are managed in `firewall_rules.tfvars`. Two Rule Collection Groups are deployed:

### `infra` (priority 1000)

| Collection | Priority | Type | Purpose |
|------------|----------|------|---------|
| `EastWest-WorkloadToIdentity` | 100 | Network | Workload VNets → identity spoke (full AD port set, per stamp) |
| `EastWest-IdentityToWorkload` | 200 | Network | Identity spoke → workload VNets (RPC callbacks, DNS, SMB) |
| `Identity-NTP` | 300 | Network | Identity → `time.windows.com` UDP/123 |
| `Identity-EntraCloudSync` | 400 | Application | Identity → Entra Cloud Sync FQDNs (HTTPS) |

### `avd` (priority 2000)

Production IP groups only — AVD session hosts run in prod.

| Collection | Priority | Type | Purpose |
|------------|----------|------|---------|
| `AVD-Network-Required` | 100 | Network | Service tags (WVD, AAD, Monitor, AzureCloud), RDP Shortpath UDP/3478, KMS TCP/1688, IMDS TCP/80 |
| `AVD-Management-Access` | 200 | Network | Prod → test + preprod per stamp (TCP 22, 3389, 5985, 5986) |
| `AVD-Certs-Required` | 300 | Application | Certificate validation endpoints (HTTP) |
| `AVD-App-Optional` | 400 | Application | Windows Update FQDN tags, telemetry |

## Adding New Rules

Add a new Rule Collection Group in `firewall_rules.tfvars`:

```hcl
firewall_rules = {
  infra = { ... }   # existing
  avd   = { ... }   # existing

  my_new_rcg = {
    priority = 3000

    network_collections = [
      {
        name     = "MyRules"
        priority = 100
        action   = "Allow"
        rules = [
          {
            name                      = "example"
            source_ip_group_keys      = ["aklc-prod"]
            destination_addresses     = ["AzureStorage"]
            protocols                 = ["TCP"]
            destination_ports         = ["443"]
          }
        ]
      }
    ]

    application_collections = []
    nat_collections         = []
  }
}
```

Then plan and apply with both var-files.

## Priority Reference

Priorities must be unique across **all** collection types (network, application, NAT) within a single RCG.

| RCG range | Purpose |
|-----------|---------|
| 1000-1999 | Infrastructure / east-west / identity |
| 2000-2999 | Workload platform services |
| 3000-3999 | Workload egress |
| 4000-4999 | DNAT / inbound |

## Azure Firewall Limits

| Limit | Value |
|-------|-------|
| Rule Collection Groups per policy | 90 |
| Size per RCG | 2 MB |
| Unique source/destination combos per policy | 20,000 |
| FQDNs in network rules | 1,000 |

## Requirements

- Terraform >= 1.9.0
- AzureRM provider >= 4.0, < 5.0
- Contributor access to the target subscription
