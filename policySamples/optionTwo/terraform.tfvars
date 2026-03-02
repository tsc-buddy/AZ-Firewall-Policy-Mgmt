# Option 2: terraform.tfvars for YAML-based configuration
enable_telemetry = true
location = "australiaeast"
firewall_policy_name = "azfw-policy-option2"
resource_group_name = "azfwpolicy-rg-option2"

# Path to the YAML configuration file
firewall_rules_config_file = "firewall_rules.yaml"
