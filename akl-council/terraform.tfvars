subscription_id  = "a97e5e9d-4ea4-427a-8646-8ab65ea003a5"
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
tags = {
  cost_centre = "IT-001"
  owner       = "platform-team"
}

# ─── Stamps ────────────────────────────────────────────────────────────────────
# Each stamp = one customer environment (3 workload VNets + 1 identity spoke).
# Creates IP Groups: ipg-<key>-workloads and ipg-<key>-identity per stamp.
# Replace placeholder CIDRs with actual VNet address prefixes.
stamps = {
  aklc = {
    test_address_prefix     = "10.10.0.0/24"
    preprod_address_prefix  = "10.11.0.0/24"
    prod_address_prefix     = "10.12.0.0/24"
    identity_address_prefix = "10.10.100.0/24"
  }
  gss = {
    test_address_prefix     = "10.20.0.0/24"
    preprod_address_prefix  = "10.21.0.0/24"
    prod_address_prefix     = "10.22.0.0/24"
    identity_address_prefix = "10.20.100.0/24"
  }
  wsl = {
    test_address_prefix     = "10.30.0.0/24"
    preprod_address_prefix  = "10.31.0.0/24"
    prod_address_prefix     = "10.32.0.0/24"
    identity_address_prefix = "10.30.100.0/24"
  }
}
