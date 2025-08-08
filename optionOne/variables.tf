# Option 1: Variable-based configuration
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
  default     = "azfw-policy-option1"
  description = "The name of the firewall policy"
}

variable "resource_group_name" {
  type        = string
  default     = "azfwpolicy-rg-option1"
  description = "The name of the resource group"
}

variable "firewall_rule_collection_groups" {
  type = map(object({
    priority = number
    network_rule_collections = optional(list(object({
      action   = string
      name     = string
      priority = number
      rules = list(object({
        name                  = string
        source_addresses      = list(string)
        destination_fqdns     = optional(list(string))
        destination_addresses = optional(list(string))
        protocols             = list(string)
        destination_ports     = list(string)
      }))
    })), [])
    application_rule_collections = optional(list(object({
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
  }))
  description = "Map of firewall rule collection groups with their configurations"
  default = {
    avd_core = {
      priority = 1000
      network_rule_collections = [{
        action   = "Allow"
        name     = "AVDCoreNetworkRules"
        priority = 500
        rules = [
          {
            name              = "Login to Microsoft"
            source_addresses  = ["10.100.0.0/24"]
            destination_fqdns = ["login.microsoftonline.com"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            name                  = "AVD"
            source_addresses      = ["10.100.0.0/24"]
            destination_addresses = ["WindowsVirtualDesktop", "AzureFrontDoor.Frontend", "AzureMonitor"]
            protocols             = ["TCP"]
            destination_ports     = ["443"]
          },
          {
            name              = "GCS"
            source_addresses  = ["10.100.0.0/24"]
            destination_fqdns = ["gcs.prod.monitoring.core.windows.net"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            name                  = "DNS"
            source_addresses      = ["10.100.0.0/24"]
            destination_addresses = ["AzureDNS"]
            protocols             = ["TCP", "UDP"]
            destination_ports     = ["53"]
          }
        ]
      }]
    }
    avd_optional = {
      priority = 1050
      network_rule_collections = [{
        action   = "Allow"
        name     = "AVDOptionalNetworkRules"
        priority = 500
        rules = [
          {
            name              = "time"
            source_addresses  = ["10.0.0.0/24"]
            destination_fqdns = ["time.windows.com"]
            protocols         = ["UDP"]
            destination_ports = ["123"]
          }
        ]
      }]
      application_rule_collections = [{
        action   = "Allow"
        name     = "AVDOptionalApplicationRules"
        priority = 600
        rules = [
          {
            name                  = "Windows"
            source_addresses      = ["10.0.0.0/24"]
            destination_fqdn_tags = ["WindowsUpdate", "WindowsDiagnostics", "MicrosoftActiveProtectionService"]
            protocols = [{
              port = 443
              type = "Https"
            }]
          }
        ]
      }]
    }
  }
}
