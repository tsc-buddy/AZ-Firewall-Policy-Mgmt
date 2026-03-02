locals {
  # ─── Naming Convention ──────────────────────────────────────────────────────
  # Pattern : <shortcode>-<app_code>-hub-<environment_code>-<location_code>-01
  # Set app_code, environment_code, and location_code in terraform.tfvars.
  name_suffix = "${var.app_code}-hub-${var.environment_code}-${var.location_code}-01"

  names = {
    resource_group  = "rg-${local.name_suffix}"
    vnet            = "vnet-${local.name_suffix}"
    firewall        = "azfw-${local.name_suffix}"
    firewall_policy = "afwp-${local.name_suffix}"
    firewall_pip    = "pip-${local.name_suffix}"
  }

  # IP Group naming: ipg-<stamp>-<tier>-<location_code>-01
  # The stamp key identifies the customer; tier identifies the workload band.
  # app_code and environment_code are intentionally excluded — these groups
  # span all customer environments and are not platform-tier-specific.
  ipg_suffix = "${var.location_code}-01"

  # ─── Mandatory Tags ─────────────────────────────────────────────────────────
  mandatory_tags = {
    managed_by  = "terraform"
    environment = var.environment_code
    workload    = "hub-network"
    customer    = "akl-council"
  }

  tags = merge(local.mandatory_tags, var.tags)

  # ─── IP Group ID Lookup ─────────────────────────────────────────────────────
  # Resolves stamp IP group keys to Azure resource IDs.
  # Use these keys in firewall_rules.tfvars via source_ip_group_keys / destination_ip_group_keys:
  #   "<stamp>-test"     e.g. "aklc-test"
  #   "<stamp>-preprod"  e.g. "aklc-preprod"
  #   "<stamp>-prod"     e.g. "aklc-prod"
  #   "<stamp>-identity" e.g. "aklc-identity"
  ip_groups = merge(
    { for k, v in azurerm_ip_group.stamp_test : "${k}-test" => v.id },
    { for k, v in azurerm_ip_group.stamp_preprod : "${k}-preprod" => v.id },
    { for k, v in azurerm_ip_group.stamp_prod : "${k}-prod" => v.id },
    { for k, v in azurerm_ip_group.stamp_identity : "${k}-identity" => v.id }
  )
}
