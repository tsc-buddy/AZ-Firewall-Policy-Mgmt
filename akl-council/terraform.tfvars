enable_telemetry = true
location         = "newzealandnorth"

# ─── Naming Convention ─────────────────────────────────────────────────────────
# Produces: <shortcode>-<app_code>-<environment_code>-<location_code>-01
# e.g. azfw-gis-prod-nzn-01
app_code         = "hub"
environment_code = "prod"
location_code    = "nzn"

# ─── Hub Virtual Network ───────────────────────────────────────────────────────
vnet_address_space = ["10.0.0.0/16"]

# AzureFirewallSubnet requires a minimum of /26
firewall_subnet_address_prefix = "10.0.0.0/26"

# AzureBastionSubnet requires a minimum of /26
bastion_subnet_address_prefix = "10.0.0.64/26"

# ─── Firewall Policy ───────────────────────────────────────────────────────────
firewall_policy_sku  = "Standard"

# ─── Azure Firewall ────────────────────────────────────────────────────────────
firewall_sku_tier = "Standard"

# newzealandnorth does not currently support Availability Zones.
# Set to null to deploy without zone pinning.
firewall_zones = null

# ─── Diagnostics ───────────────────────────────────────────────────────────────
# Replace with the actual resource ID of your Log Analytics Workspace.
log_analytics_workspace_id = "/subscriptions/a97e5e9d-4ea4-427a-8646-8ab65ea003a5/resourceGroups/dc-poc/providers/Microsoft.OperationalInsights/workspaces/poc-law"

# ─── Tags ──────────────────────────────────────────────────────────────────────
# These are merged with the mandatory tags defined in locals.tf.
tags = {}

# ─── Stamps ────────────────────────────────────────────────────────────────────
# Each stamp = one customer environment (3 workload VNets + 1 identity spoke).
# Creates IP Groups: ipg-<key>-workloads and ipg-<key>-identity per stamp.
# Replace placeholder CIDRs with actual VNet address prefixes.
stamps = {
  aklc = {
    dev_address_prefix      = "10.132.0.0/23"
    test_address_prefix     = "10.132.2.3/23"
    preprod_address_prefix  = "10.132.4.0/23"
    prod_address_prefix     = "10.132.6.0/23"
    identity_address_prefix = "10.132.10.0/25"
  }
  gss = {
    dev_address_prefix      = "10.132.16.0/23"
    test_address_prefix     = "10.132.18.0/23"
    preprod_address_prefix  = "10.132.20.0/23"
    prod_address_prefix     = "10.132.22.0/23"
    identity_address_prefix = "10.132.26.0/25"
  }
  wsl = {
    dev_address_prefix      = "10.132.32.0/23"
    test_address_prefix     = "10.132.34.0/23"
    preprod_address_prefix  = "10.132.36.0/23"
    prod_address_prefix     = "10.132.38.0/23"
    identity_address_prefix = "10.132.42.0/25"
  }
}
