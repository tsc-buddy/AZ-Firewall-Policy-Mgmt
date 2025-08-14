# Option 3A: terraform.tfvars with direct rule declarations
enable_telemetry     = true
location             = "australiaeast"
firewall_policy_name = "azfw-policy-option3a"
resource_group_name  = "azfwpolicy-rg-option3a"

# Direct firewall rules configuration - all rules are clearly visible here
firewall_rules = {
  # AVD Rules - Combined core and optional in single rule collection group
  avd = {
    priority      = 1000
    source_subnet = "10.100.0.0/24"
    network_collections = [
      {
        action   = "Allow"
        name     = "AVDCoreNetworkRules"
        priority = 500
        rules = [
          {
            name              = "Login to Microsoft"
            destination_fqdns = ["login.microsoftonline.com"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            name                  = "AVD"
            destination_addresses = ["WindowsVirtualDesktop", "AzureFrontDoor.Frontend", "AzureMonitor"]
            protocols             = ["TCP"]
            destination_ports     = ["443"]
          },
          {
            name              = "GCS"
            destination_fqdns = ["gcs.prod.monitoring.core.windows.net"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
          },
          {
            name                  = "DNS"
            destination_addresses = ["AzureDNS"]
            protocols             = ["TCP", "UDP"]
            destination_ports     = ["53"]
          },
          {
            name              = "azkms"
            destination_fqdns = ["azkms.core.windows.net"]
            protocols         = ["TCP"]
            destination_ports = ["1688"]
          },
          {
            name              = "KMS"
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
            destination_fqdns = ["time.windows.com"]
            protocols         = ["UDP"]
            destination_ports = ["123"]
          },
          {
            name              = "login windows.net"
            destination_fqdns = ["login.windows.net"]
            protocols         = ["TCP"]
            destination_ports = ["443"]
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

  # M365 Rules
  m365 = {
    priority      = 2000
    source_subnet = "10.0.0.0/24"
    network_collections = [
      {
        action   = "Allow"
        name     = "M365NetworkRules"
        priority = 500
        rules = [
          {
            name                  = "M365"
            destination_addresses = ["Office365.Common.Allow.Required"]
            protocols             = ["TCP"]
            destination_ports     = ["443"]
          }
        ]
      }
    ]
    application_collections = []
  }

  # Internet Access Rules
  internet = {
    priority      = 3000
    source_subnet = "10.0.0.0/24"
    network_collections = [
      {
        action   = "Allow"
        name     = "InternetNetworkRules"
        priority = 500
        rules = [
          {
            name                  = "Internet"
            destination_addresses = ["*"]
            protocols             = ["TCP"]
            destination_ports     = ["443", "80"]
          }
        ]
      }
    ]
    application_collections = []
  }
}
