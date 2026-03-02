variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID to deploy resources into."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
Controls whether telemetry is enabled for AVM modules.
See https://aka.ms/avm/telemetryinfo for details.
DESCRIPTION
}

# ─── Location ─────────────────────────────────────────────────────────────────

variable "location" {
  type        = string
  description = "Azure region for all resources."
}

# ─── Naming Convention ────────────────────────────────────────────────────────
# All resource names are derived in locals.tf using the pattern:
#   <shortcode>-<app_code>-<environment_code>-<location_code>-01

variable "app_code" {
  type        = string
  description = "Short application/platform identifier used in resource names. e.g. 'gis'."
}

variable "environment_code" {
  type        = string
  description = "Environment identifier used in resource names. e.g. 'prod', 'nonprod'."
}

variable "location_code" {
  type        = string
  description = "Short location/region code used in resource names. e.g. 'nzn' for New Zealand North."
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the hub VNet. e.g. [\"10.0.0.0/16\"]"
}

variable "firewall_subnet_address_prefix" {
  type        = string
  description = "Address prefix for AzureFirewallSubnet. Minimum /26 required by Azure."
}

variable "bastion_subnet_address_prefix" {
  type        = string
  description = "Address prefix for AzureBastionSubnet. Minimum /26 required by Azure."
}

# ─── Firewall Policy ───────────────────────────────────────────────────────────

variable "firewall_policy_sku" {
  type        = string
  default     = "Standard"
  description = "SKU of the Firewall Policy. Possible values: Standard, Premium, Basic."
}

# ─── Azure Firewall ────────────────────────────────────────────────────────────

variable "firewall_sku_tier" {
  type        = string
  default     = "Standard"
  description = "SKU tier of the Azure Firewall. Possible values: Standard, Premium, Basic."
}

variable "firewall_zones" {
  type        = set(string)
  default     = null
  nullable    = true
  description = "Availability Zones for the Azure Firewall. Set to null if the region does not support zones (e.g. newzealandnorth)."
}

# ─── Diagnostics ───────────────────────────────────────────────────────────────

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the existing Log Analytics Workspace for diagnostic settings."
}

# ─── Tags ──────────────────────────────────────────────────────────────────────

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources. Merged with mandatory tags defined in locals."
}

# ─── Stamps ───────────────────────────────────────────────────────────────────
# Each stamp represents a customer environment with five workload tiers + 1 identity spoke.
# Five IP Groups are created per stamp:
#   "<key>-dev"      → developer workload VNet CIDR
#   "<key>-test"      → test workload VNet CIDR
#   "<key>-preprod"   → pre-production workload VNet CIDR
#   "<key>-prod"      → production workload VNet CIDR
#   "<key>-identity"  → identity spoke CIDR
# Reference these keys in firewall_rules.tfvars via source_ip_group_keys / destination_ip_group_keys.

variable "stamps" {
  type = map(object({
    dev_address_prefix      = string
    test_address_prefix     = string
    preprod_address_prefix  = string
    prod_address_prefix     = string
    identity_address_prefix = string
  }))
  description = <<DESCRIPTION
Map of stamps (customer environments) managed by this firewall.
Each stamp creates five IP Groups: "<key>-dev", "<key>-test", "<key>-preprod", "<key>-prod", "<key>-identity".
DESCRIPTION
}

# ─── Firewall Rules (Option 3 pattern) ────────────────────────────────────────

variable "firewall_rules" {
  type = map(object({
    priority = number
    network_collections = optional(list(object({
      action   = string
      name     = string
      priority = number
      rules = list(object({
        name                      = string
        source_addresses          = optional(list(string))
        source_ip_group_keys      = optional(list(string))
        destination_fqdns         = optional(list(string))
        destination_addresses     = optional(list(string))
        destination_ip_group_keys = optional(list(string))
        protocols                 = list(string)
        destination_ports         = optional(list(string))
      }))
    })), [])
    application_collections = optional(list(object({
      action   = string
      name     = string
      priority = number
      rules = list(object({
        name                  = string
        source_addresses      = optional(list(string))
        source_ip_group_keys  = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_fqdn_tags = optional(list(string))
        protocols = list(object({
          port = number
          type = string
        }))
      }))
    })), [])
    nat_collections = optional(list(object({
      action   = string
      name     = string
      priority = number
      rules = list(object({
        name                 = string
        source_addresses     = optional(list(string))
        source_ip_group_keys = optional(list(string))
        destination_address  = string
        destination_ports   = list(string)
        translated_address  = string
        translated_port     = string
        protocols           = list(string)
      }))
    })), [])
  }))
  description = "Map of firewall rule collection groups. source_addresses is defined per-rule for full granularity. Supplied via firewall_rules.tfvars."
}
