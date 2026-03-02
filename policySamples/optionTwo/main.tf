# Option 2: YAML file-based configuration

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

# Dynamic rule collection groups using YAML configuration
module "rule_collection_groups" {
  source   = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"
  for_each = local.firewall_rules

  firewall_policy_rule_collection_group_firewall_policy_id = module.firewall_policy.resource.id
  firewall_policy_rule_collection_group_name               = "${title(each.key)}RuleCollectionGroup"
  firewall_policy_rule_collection_group_priority           = each.value.priority

  # Network rule collections
  firewall_policy_rule_collection_group_network_rule_collection = [
    for collection in try(each.value.network_rule_collections, []) : {
      action   = collection.action
      name     = collection.name
      priority = collection.priority
      rule = [
        for rule in collection.rules : {
          name                  = rule.name
          source_addresses      = rule.source_addresses
          destination_fqdns     = try(rule.destination_fqdns, null)
          destination_addresses = try(rule.destination_addresses, null)
          protocols             = rule.protocols
          destination_ports     = rule.destination_ports
        }
      ]
    }
  ]

  # Application rule collections
  firewall_policy_rule_collection_group_application_rule_collection = [
    for collection in try(each.value.application_rule_collections, []) : {
      action   = collection.action
      name     = collection.name
      priority = collection.priority
      rule = [
        for rule in collection.rules : {
          name                  = rule.name
          source_addresses      = rule.source_addresses
          destination_fqdns     = try(rule.destination_fqdns, null)
          destination_fqdn_tags = try(rule.destination_fqdn_tags, null)
          protocols             = rule.protocols
        }
      ]
    }
  ]
}
