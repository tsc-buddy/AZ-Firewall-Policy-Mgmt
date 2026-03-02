subscription_id      = "00000000-0000-0000-0000-000000000000"
enable_telemetry     = true
location             = "newzealandnorth"
firewall_policy_name = "azfw-policy-option3"
resource_group_name  = "azfwpolicy-rg-option3"

firewall_rules = {
  # ─────────────────────────────────────────────
  # AVD Rule Collection Group (priority 1000)
  # source_addresses defined per-rule for full control.
  # ─────────────────────────────────────────────
  avd = {
    priority = 1000
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
            name                  = "AVD Service Tags"
            source_addresses      = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_addresses = ["WindowsVirtualDesktop", "AzureFrontDoor.Frontend", "AzureMonitor"]
            protocols             = ["TCP"]
            destination_ports     = ["443"]
          },
          {
            name              = "GCS"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24"]
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
            name              = "NTP"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_fqdns = ["time.windows.com"]
            protocols         = ["UDP"]
            destination_ports = ["123"]
          },
          {
            name              = "Login Windows"
            source_addresses  = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_fqdns = ["login.windows.net"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            # ICMP - destination_ports intentionally omitted (not valid for ICMP)
            name                  = "ICMP to AzureDNS"
            source_addresses      = ["10.100.0.0/24", "10.101.0.0/24"]
            destination_addresses = ["AzureDNS"]
            protocols             = ["ICMP"]
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
            name                  = "Windows Updates and Diagnostics"
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
            name              = "Microsoft Events"
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
  }

  # ─────────────────────────────────────────────
  # M365 Rule Collection Group (priority 2000)
  # ─────────────────────────────────────────────
  m365 = {
    priority = 2000
    network_collections = [
      {
        action   = "Allow"
        name     = "M365NetworkRules"
        priority = 500
        rules = [
          {
            name                  = "M365 Required"
            source_addresses      = ["10.0.0.0/24", "192.168.0.0/24"]
            destination_addresses = ["Office365.Common.Allow.Required"]
            protocols             = ["TCP"]
            destination_ports     = ["443"]
          }
        ]
      }
    ]
  }

  # ─────────────────────────────────────────────
  # Internet Access Rule Collection Group (priority 3000)
  # ─────────────────────────────────────────────
  internet = {
    priority = 3000
    network_collections = [
      {
        action   = "Allow"
        name     = "InternetNetworkRules"
        priority = 500
        rules = [
          {
            name                  = "General Internet"
            source_addresses      = ["10.0.0.0/24"]
            destination_addresses = ["*"]
            protocols             = ["TCP"]
            destination_ports     = ["443", "80"]
          }
        ]
      }
    ]
  }

  # ─────────────────────────────────────────────
  # DNAT Example - uncomment and customise when needed
  # ─────────────────────────────────────────────
  # dnat_services = {
  #   priority = 4000
  #   nat_collections = [
  #     {
  #       action   = "Dnat"
  #       name     = "PublicServicesDNAT"
  #       priority = 100
  #       rules = [
  #         {
  #           name                = "WebServer"
  #           source_addresses    = ["*"]
  #           destination_address = "20.53.1.100"   # Firewall public IP
  #           destination_ports   = ["80", "443"]
  #           translated_address  = "10.0.1.10"     # Internal server IP
  #           translated_port     = "80"
  #           protocols           = ["TCP"]
  #         },
  #         {
  #           name                = "SSHAccess"
  #           source_addresses    = ["203.0.113.0/24"]
  #           destination_address = "20.53.1.100"
  #           destination_ports   = ["2222"]
  #           translated_address  = "10.0.1.5"
  #           translated_port     = "22"
  #           protocols           = ["TCP"]
  #         }
  #       ]
  #     }
  #   ]
  # }
}
