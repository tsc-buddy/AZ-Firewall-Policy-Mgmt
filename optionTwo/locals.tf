locals {
  # Load firewall rules from YAML file
  firewall_rules = yamldecode(file(var.firewall_rules_config_file))
}
