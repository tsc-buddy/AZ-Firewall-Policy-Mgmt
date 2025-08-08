# Option 1: Main configuration using for_each with structured variables

resource "azurerm_resource_group" "azfw-rg" {
  location = var.location
  name     = var.resource_group_name
}

module "firewall_policy" {
  source = "Azure/avm-res-network-firewallpolicy/azurerm"
  enable_telemetry    = var.enable_telemetry
  name                = var.firewall_policy_name
  location            = var.location
  resource_group_name = azurerm_resource_group.azfw-rg.name
  firewall_policy_dns = {
    proxy_enabled = true
  }
}

# Dynamic rule collection groups using for_each
module "rule_collection_groups" {
  source   = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"
  for_each = var.firewall_rule_collection_groups

  firewall_policy_rule_collection_group_firewall_policy_id = module.firewall_policy.resource.id
  firewall_policy_rule_collection_group_name               = "${title(each.key)}RuleCollectionGroup"
  firewall_policy_rule_collection_group_priority           = each.value.priority

  # Network rule collections
  firewall_policy_rule_collection_group_network_rule_collection = [
    for collection in each.value.network_rule_collections : {
      action   = collection.action
      name     = collection.name
      priority = collection.priority
      rule = [
        for rule in collection.rules : {
          name                  = rule.name
          source_addresses      = rule.source_addresses
          destination_fqdns     = rule.destination_fqdns
          destination_addresses = rule.destination_addresses
          protocols             = rule.protocols
          destination_ports     = rule.destination_ports
        }
      ]
    }
  ]

  # Application rule collections
  firewall_policy_rule_collection_group_application_rule_collection = [
    for collection in each.value.application_rule_collections : {
      action   = collection.action
      name     = collection.name
      priority = collection.priority
      rule = [
        for rule in collection.rules : {
          name                  = rule.name
          source_addresses      = rule.source_addresses
          destination_fqdns     = rule.destination_fqdns
          destination_fqdn_tags = rule.destination_fqdn_tags
          protocols             = rule.protocols
        }
      ]
    }
  ]
}
