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

variable "network_segments" {
  type = map(string)
  description = "Map of network segments and their CIDR blocks"
  default = {
    avd_subnet = "10.100.0.0/24"
    general_subnet = "10.0.0.0/24"
  }
}

variable "enabled_rule_sets" {
  type = list(string)
  description = "List of rule sets to enable"
  default = ["avd_core", "avd_optional", "m365", "internet"]
}

variable "rule_collection_group_priorities" {
  type = map(number)
  description = "Priority mapping for rule collection groups"
  default = {
    avd_core = 1000
    avd_optional = 1050
    m365 = 2000
    internet = 3000
  }
}
