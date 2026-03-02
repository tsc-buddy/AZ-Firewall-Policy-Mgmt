# Option 3: Variable definitions
variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID to deploy resources into."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "location" {
  type        = string
  default     = "newzealandnorth"
  description = "The Azure region where resources will be deployed."
}

variable "firewall_policy_name" {
  type        = string
  description = "The name of the firewall policy."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "firewall_rules" {
  type = map(object({
    priority = number
    network_collections = optional(list(object({
      action   = string
      name     = string
      priority = number
      rules = list(object({
        name                  = string
        source_addresses      = list(string)
        destination_fqdns     = optional(list(string))
        destination_addresses = optional(list(string))
        protocols             = list(string)
        destination_ports     = optional(list(string))
      }))
    })), [])
    application_collections = optional(list(object({
      action   = string
      name     = string
      priority = number
      rules = list(object({
        name                  = string
        source_addresses      = list(string)
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
        name                = string
        source_addresses    = list(string)
        destination_address = string
        destination_ports   = list(string)
        translated_address  = string
        translated_port     = string
        protocols           = list(string)
      }))
    })), [])
  }))
  description = "Map of firewall rule collection groups. source_addresses is defined per-rule for full granularity across network, application, and NAT collections."
}
