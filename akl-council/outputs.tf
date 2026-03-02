output "hub_vnet_id" {
  description = "Resource ID of the hub Virtual Network."
  value       = module.hub_vnet.resource_id
}

output "firewall_subnet_id" {
  description = "Resource ID of the AzureFirewallSubnet."
  value       = module.hub_vnet.subnets["firewall"].resource_id
}

output "bastion_subnet_id" {
  description = "Resource ID of the AzureBastionSubnet."
  value       = module.hub_vnet.subnets["bastion"].resource_id
}

output "firewall_id" {
  description = "Resource ID of the Azure Firewall."
  value       = module.firewall.resource_id
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall. Use this as the next-hop in UDRs."
  value       = module.firewall.resource.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Public IP address of the Azure Firewall."
  value       = module.fw_public_ip.public_ip_address
}

output "firewall_policy_id" {
  description = "Resource ID of the Azure Firewall Policy."
  value       = module.firewall_policy.resource.id
}
