# Option 3: Modular approach with rule templates
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
  default     = "australiaeast"
  description = "The Azure region where resources will be deployed"
}

variable "firewall_policy_name" {
  type        = string
  default     = "azfw-policy-option3"
  description = "The name of the firewall policy"
}

variable "resource_group_name" {
  type        = string
  default     = "azfwpolicy-rg-option3"
  description = "The name of the resource group"
}

variable "firewall_rules" {
  type = map(object({
    priority        = number
    network_collections = optional(list(object({
      action   = string
      name     = string
      priority = number
      rules = list(object({
        name                  = string
        source_addresses      = list(string)  # Required at rule level only
        destination_fqdns     = optional(list(string))
        destination_addresses = optional(list(string))
        protocols             = list(string)
        destination_ports     = optional(list(string))  # Made optional for ICMP and other protocols
      }))
    })), [])
    application_collections = optional(list(object({
      action   = string
      name     = string
      priority = number
      rules = list(object({
        name                  = string
        source_addresses      = list(string)  # Required at rule level only
        destination_fqdns     = optional(list(string))
        destination_fqdn_tags = optional(list(string))
        protocols = list(object({
          port = number
          type = string
        }))
      }))
    })), [])
    nat_collections = optional(list(object({
      action   = string  # Typically "Dnat"
      name     = string
      priority = number
      rules = list(object({
        name               = string
        source_addresses   = list(string)  # Required at rule level only
        destination_address = string                 # Public IP address
        destination_ports  = list(string)
        translated_address = string                  # Internal IP address
        translated_port    = string                  # Internal port
        protocols          = list(string)
      }))
    })), [])
  }))
  description = "Firewall rules configuration with direct rule declarations. Source addresses are defined at the individual rule level for maximum granular control."
}
