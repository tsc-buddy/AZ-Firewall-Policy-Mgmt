# Option 3: terraform.tfvars for modular template approach
enable_telemetry = true
location = "australiaeast"
firewall_policy_name = "azfw-policy-option3"
resource_group_name = "azfwpolicy-rg-option3"

# Network segments configuration
network_segments = {
  avd_subnet     = "10.100.0.0/24"
  general_subnet = "10.0.0.0/24"
  dmz_subnet     = "10.200.0.0/24"
}

# Which rule sets to enable
enabled_rule_sets = ["avd_core", "avd_optional", "m365", "internet"]

# Priority configuration for rule collection groups
rule_collection_group_priorities = {
  avd_core     = 1000
  avd_optional = 1050
  m365         = 2000
  internet     = 3000
  custom       = 4000
}
