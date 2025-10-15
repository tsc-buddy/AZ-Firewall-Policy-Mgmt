# Option 3A: terraform.tfvars with direct rule declarations
enable_telemetry     = true
location             = "australiaeast"
firewall_policy_name = "azfw-policy-option3a"
resource_group_name  = "azfwpolicy-rg-option3a"

# Direct firewall rules configuration - all rules are clearly visible here
firewall_rules = {
  # AVD Rules - Combined core and optional in single rule collection group
  avd = {
    priority         = 1000
    network_collections = [
      {
        action   = "Allow"
        name     = "AVDCoreNetworkRules"
        priority = 500
        rules = [
          {
            name              = "Login to Microsoft"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_fqdns = ["login.microsoftonline.com"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            name                  = "AVD"
            source_addresses      = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_addresses = ["WindowsVirtualDesktop", "AzureFrontDoor.Frontend", "AzureMonitor"]
            protocols             = ["TCP"]
            destination_ports     = ["443"]
          },
          {
            name              = "GCS"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24", "10.222.222.0/24"]
            destination_fqdns = ["gcs.prod.monitoring.core.windows.net"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            name                  = "DNS"
            source_addresses      = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_addresses = ["AzureDNS"]
            protocols             = ["TCP", "UDP"]
            destination_ports     = ["53"]
          },
          {
            name              = "azkms"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_fqdns = ["azkms.core.windows.net"]
            protocols         = ["TCP"]
            destination_ports = ["1688"]
          },
          {
            name              = "KMS"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_fqdns = ["kms.core.windows.net"]
            protocols         = ["TCP"]
            destination_ports = ["1688"]
          }
        ]
      },
      {
        action   = "Allow"
        name     = "AVDOptionalNetworkRules"
        priority = 510
        rules = [
          {
            name              = "time"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_fqdns = ["time.windows.com"]
            protocols         = ["UDP"]
            destination_ports = ["123"]
          },
          {
            name              = "login windows.net"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_fqdns = ["login.windows.net"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            name                  = "ICMP Echo"
            source_addresses      = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_addresses = ["AzureDNS"]
            protocols             = ["ICMP"]
            destination_ports     = ["*"]  # Required for ICMP rules in Azure Firewall
          }
        ]
      }
    ]
    application_collections = [
      {
        action   = "Allow"
        name     = "AVDOptionalApplicationRules"
        priority = 600
        rules = [
          {
            name                  = "Windows Updates"
            source_addresses      = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_fqdn_tags = ["WindowsUpdate", "WindowsDiagnostics", "MicrosoftActiveProtectionService"]
            protocols = [
              {
                port = 443
                type = "Https"
              }
            ]
          },
          {
            name              = "Events"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_fqdns = ["*.events.data.microsoft.com"]
            protocols = [
              {
                port = 443
                type = "Https"
              }
            ]
          }
        ]
      }
    ]
    nat_collections = []  # No DNAT rules in AVD collection
  }

  # M365 Rules
  m365 = {
    priority         = 2000
    network_collections = [
      {
        action   = "Allow"
        name     = "M365NetworkRules"
        priority = 500
        rules = [
          {
            name                  = "M365"
            source_addresses      = ["10.0.0.0/24", "192.168.0.0/24"]
            destination_addresses = ["Office365.Common.Allow.Required"]
            protocols             = ["TCP"]
            destination_ports     = ["443"]
          }
        ]
      }
    ]
    application_collections = []
    nat_collections = []  # No DNAT rules in M365 collection
  }

  # Internet Access Rules
  internet = {
    priority         = 3000
    network_collections = [
      {
        action   = "Allow"
        name     = "InternetNetworkRules"
        priority = 500
        rules = [
          {
            name                  = "Internet"
            source_addresses      = ["10.0.0.0/24"]
            destination_addresses = ["*"]
            protocols             = ["TCP"]
            destination_ports     = ["443", "80"]
          }
        ]
      }
    ]
    application_collections = []
    nat_collections = []  # No DNAT rules configured yet
  }

  # Example demonstrating rule-level source address granular control
  mixed_sources = {
    priority         = 3500
    network_collections = [
      {
        action   = "Allow"
        name     = "MixedSourceRules"
        priority = 100
        rules = [
          {
            name              = "Admin Access"
            source_addresses  = ["10.200.1.0/24", "10.200.2.0/24"]  # Only admin subnets
            destination_fqdns = ["admin.contoso.com"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            name              = "General Access"
            source_addresses  = ["10.200.0.0/24"]  # General users subnet
            destination_fqdns = ["public.contoso.com"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            name              = "VIP Access"
            source_addresses  = ["10.200.10.0/24"]  # Only VIP subnet
            destination_fqdns = ["vip.contoso.com"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          }
        ]
      }
    ]
    application_collections = [
      {
        action   = "Allow"
        name     = "MixedSourceAppRules"
        priority = 200
        rules = [
          {
            name              = "Development Tools"
            source_addresses  = ["10.200.100.0/24"]  # Override: Only dev subnet
            destination_fqdns = ["github.com", "dev.azure.com"]
            protocols = [
              {
                port = 443
                type = "Https"
              }
            ]
          },
          {
            name              = "Standard Office Apps"
            source_addresses  = ["10.200.0.0/24"]  # General users subnet
            destination_fqdns = ["office.com", "outlook.com"]
            protocols = [
              {
                port = 443
                type = "Https"
              }
            ]
          }
        ]
      }
    ]
    nat_collections = []
  }

  # Example DNAT Rules (commented out - uncomment and customize when needed)
  /*
  dnat_services = {
    priority         = 4000
    network_collections = []
    application_collections = []
    nat_collections = [
      {
        action   = "Dnat"
        name     = "PublicServicesDNAT"
        priority = 100
        rules = [
          {
            name               = "WebServer"
            source_addresses   = ["*"]  # Allow from any source (or restrict as needed)
            destination_address = "20.53.1.100"    # Your firewall's public IP
            destination_ports  = ["80", "443"]
            translated_address = "10.0.1.10"       # Internal web server IP
            translated_port    = "80"               # Internal port (can be different)
            protocols          = ["TCP"]
          },
          {
            name               = "SSHAccess"
            source_addresses   = ["203.0.113.0/24"]  # Restrict SSH to specific public IPs
            destination_address = "20.53.1.100"      # Your firewall's public IP
            destination_ports  = ["2222"]            # Custom SSH port
            translated_address = "10.0.1.5"          # Internal jump server
            translated_port    = "22"                # Standard SSH port internally
            protocols          = ["TCP"]
          }
        ]
      }
    ]
  }
  */
}
