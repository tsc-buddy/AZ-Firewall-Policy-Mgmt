# Option 2: YAML-based configuration variables
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
  default     = "azfw-policy-option2"
  description = "The name of the firewall policy"
}

variable "resource_group_name" {
  type        = string
  default     = "azfwpolicy-rg-option2"
  description = "The name of the resource group"
}

variable "firewall_rules_config_file" {
  type        = string
  default     = "firewall_rules.yaml"
  description = "Path to the YAML file containing firewall rules configuration"
}
