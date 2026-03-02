# ─── Resource Group ────────────────────────────────────────────────────────────

resource "azurerm_resource_group" "hub" {
  name     = local.names.resource_group
  location = var.location
  tags     = local.tags
}
# ─── Stamp IP Groups ───────────────────────────────────────────────────────────────────
# No AVM module exists for azurerm_ip_group; native resource used directly.
# Keys available in firewall_rules.tfvars: "<stamp>-dev", "<stamp>-test", "<stamp>-preprod", "<stamp>-prod", "<stamp>-identity"

resource "azurerm_ip_group" "stamp_dev" {
  for_each = var.stamps

  name                = "ipg-${each.key}-dev-${local.ipg_suffix}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  cidrs               = [each.value.dev_address_prefix]
  tags                = local.tags
}

resource "azurerm_ip_group" "stamp_test" {
  for_each = var.stamps

  name                = "ipg-${each.key}-test-${local.ipg_suffix}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  cidrs               = [each.value.test_address_prefix]
  tags                = local.tags
}

resource "azurerm_ip_group" "stamp_preprod" {
  for_each = var.stamps

  name                = "ipg-${each.key}-preprod-${local.ipg_suffix}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  cidrs               = [each.value.preprod_address_prefix]
  tags                = local.tags
}

resource "azurerm_ip_group" "stamp_prod" {
  for_each = var.stamps

  name                = "ipg-${each.key}-prod-${local.ipg_suffix}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  cidrs               = [each.value.prod_address_prefix]
  tags                = local.tags
}

resource "azurerm_ip_group" "stamp_identity" {
  for_each = var.stamps

  name                = "ipg-${each.key}-identity-${local.ipg_suffix}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  cidrs               = [each.value.identity_address_prefix]
  tags                = local.tags
}
# ─── Hub Virtual Network ───────────────────────────────────────────────────────
# AzureFirewallSubnet and AzureBastionSubnet names are required by Azure.

module "hub_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = ">= 0.8.0"

  name             = local.names.vnet
  location         = azurerm_resource_group.hub.location
  parent_id        = azurerm_resource_group.hub.id
  address_space    = var.vnet_address_space
  enable_telemetry = var.enable_telemetry
  tags             = local.tags

  subnets = {
    firewall = {
      name             = "AzureFirewallSubnet"
      address_prefixes = [var.firewall_subnet_address_prefix]
    }
    bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = [var.bastion_subnet_address_prefix]
    }
  }
}

# ─── Firewall Public IP ─────────────────────────────────────────────────────────

module "fw_public_ip" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = ">= 0.1.2"

  name                = local.names.firewall_pip
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.firewall_zones
  enable_telemetry    = var.enable_telemetry
  tags                = local.tags
  # Azure automatically sets this tag on firewall PIPs; pinning it here prevents
  # forced replacement on subsequent plans due to drift detection.
  ip_tags = { "FirstPartyUsage" = "/Unprivileged" }
}

# ─── Firewall Policy ───────────────────────────────────────────────────────────

module "firewall_policy" {
  source  = "Azure/avm-res-network-firewallpolicy/azurerm"
  version = ">= 0.3.0"

  name                = local.names.firewall_policy
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  enable_telemetry    = var.enable_telemetry
  firewall_policy_sku = var.firewall_policy_sku

  firewall_policy_dns = {
    proxy_enabled = true
  }
}

# ─── Firewall Rule Collection Groups (Option 3 pattern) ───────────────────────
# Each map key in var.firewall_rules becomes its own Rule Collection Group.
# Rules are managed exclusively via firewall_rules.tfvars.

module "rule_collection_groups" {
  source   = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"
  for_each = var.firewall_rules

  firewall_policy_rule_collection_group_firewall_policy_id = module.firewall_policy.resource.id
  firewall_policy_rule_collection_group_name               = "${title(each.key)}RuleCollectionGroup"
  firewall_policy_rule_collection_group_priority           = each.value.priority

  firewall_policy_rule_collection_group_network_rule_collection = [
    for collection in each.value.network_collections : {
      action   = collection.action
      name     = collection.name
      priority = collection.priority
      rule = [
        for rule in collection.rules : {
          name                  = rule.name
          source_addresses      = try(rule.source_addresses, null)
          source_ip_groups      = rule.source_ip_group_keys != null ? [for k in rule.source_ip_group_keys : local.ip_groups[k]] : null
          destination_fqdns     = try(rule.destination_fqdns, null)
          destination_addresses = try(rule.destination_addresses, null)
          destination_ip_groups = rule.destination_ip_group_keys != null ? [for k in rule.destination_ip_group_keys : local.ip_groups[k]] : null
          protocols             = rule.protocols
          destination_ports     = try(rule.destination_ports, null)
        }
      ]
    }
  ]

  firewall_policy_rule_collection_group_application_rule_collection = [
    for collection in each.value.application_collections : {
      action   = collection.action
      name     = collection.name
      priority = collection.priority
      rule = [
        for rule in collection.rules : {
          name                  = rule.name
          source_addresses      = try(rule.source_addresses, null)
          source_ip_groups      = rule.source_ip_group_keys != null ? [for k in rule.source_ip_group_keys : local.ip_groups[k]] : null
          destination_fqdns     = try(rule.destination_fqdns, null)
          destination_fqdn_tags = try(rule.destination_fqdn_tags, null)
          protocols             = rule.protocols
        }
      ]
    }
  ]

  firewall_policy_rule_collection_group_nat_rule_collection = [
    for collection in each.value.nat_collections : {
      action   = collection.action
      name     = collection.name
      priority = collection.priority
      rule = [
        for rule in collection.rules : {
          name                = rule.name
          source_addresses    = try(rule.source_addresses, null)
          source_ip_groups    = rule.source_ip_group_keys != null ? [for k in rule.source_ip_group_keys : local.ip_groups[k]] : null
          destination_address = rule.destination_address
          destination_ports   = rule.destination_ports
          translated_address  = rule.translated_address
          translated_port     = rule.translated_port
          protocols           = rule.protocols
        }
      ]
    }
  ]
}

# ─── Azure Firewall ────────────────────────────────────────────────────────────

module "firewall" {
  source  = "Azure/avm-res-network-azurefirewall/azurerm"
  version = ">= 0.3.0"

  name                = local.names.firewall
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  firewall_sku_name   = "AZFW_VNet"
  firewall_sku_tier   = var.firewall_sku_tier
  firewall_zones      = var.firewall_zones
  firewall_policy_id  = module.firewall_policy.resource.id
  enable_telemetry    = var.enable_telemetry
  tags                = local.tags

  ip_configurations = {
    default = {
      name                 = "ipconfig1"
      subnet_id            = module.hub_vnet.subnets["firewall"].resource_id
      public_ip_address_id = module.fw_public_ip.public_ip_id
    }
  }

  diagnostic_settings = {
    to_law = {
      name                  = "diag-${local.names.firewall}"
      workspace_resource_id = var.log_analytics_workspace_id
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  }

  depends_on = [module.hub_vnet]
}
