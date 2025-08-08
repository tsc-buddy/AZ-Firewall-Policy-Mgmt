# Option 1: terraform.tfvars for variable-based configuration
enable_telemetry = true
location = "australiaeast"
firewall_policy_name = "azfw-policy-option1"
resource_group_name = "azfwpolicy-rg-option1"

firewall_rule_collection_groups = {
  avd_core = {
    priority = 1000
    network_rule_collections = [{
      action   = "Allow"
      name     = "AVDCoreNetworkRules"
      priority = 500
      rules = [
        {
          name              = "Login to Microsoft"
          source_addresses  = ["10.100.0.0/24"]
          destination_fqdns = ["login.microsoftonline.com"]
          protocols         = ["TCP"]
          destination_ports = ["443"]
        },
        {
          name                  = "AVD"
          source_addresses      = ["10.100.0.0/24"]
          destination_addresses = ["WindowsVirtualDesktop", "AzureFrontDoor.Frontend", "AzureMonitor"]
          protocols             = ["TCP"]
          destination_ports     = ["443"]
        },
        {
          name              = "GCS"
          source_addresses  = ["10.100.0.0/24"]
          destination_fqdns = ["gcs.prod.monitoring.core.windows.net"]
          protocols         = ["TCP"]
          destination_ports = ["443"]
        },
        {
          name                  = "DNS"
          source_addresses      = ["10.100.0.0/24"]
          destination_addresses = ["AzureDNS"]
          protocols             = ["TCP", "UDP"]
          destination_ports     = ["53"]
        },
        {
          name              = "azkms"
          source_addresses  = ["10.100.0.0/24"]
          destination_fqdns = ["azkms.core.windows.net"]
          protocols         = ["TCP"]
          destination_ports = ["1688"]
        },
        {
          name              = "KMS"
          source_addresses  = ["10.100.0.0/24"]
          destination_fqdns = ["kms.core.windows.net"]
          protocols         = ["TCP"]
          destination_ports = ["1688"]
        },
        {
          name              = "mrglobalblob"
          source_addresses  = ["10.100.0.0/24"]
          destination_fqdns = ["mrsglobalsteus2prod.blob.core.windows.net"]
          protocols         = ["TCP"]
          destination_ports = ["443"]
        },
        {
          name              = "wvdportalstorageblob"
          source_addresses  = ["10.100.0.0/24"]
          destination_fqdns = ["wvdportalstorageblob.blob.core.windows.net"]
          protocols         = ["TCP"]
          destination_ports = ["443"]
        },
        {
          name              = "oneocsp"
          source_addresses  = ["10.100.0.0/24"]
          destination_fqdns = ["oneocsp.microsoft.com"]
          protocols         = ["TCP"]
          destination_ports = ["443"]
        },
        {
          name              = "microsoft.com"
          source_addresses  = ["10.100.0.0/24"]
          destination_fqdns = ["www.microsoft.com"]
          protocols         = ["TCP"]
          destination_ports = ["443"]
        }
      ]
    }]
  }
  
  avd_optional = {
    priority = 1050
    network_rule_collections = [{
      action   = "Allow"
      name     = "AVDOptionalNetworkRules"
      priority = 500
      rules = [
        {
          name              = "time"
          source_addresses  = ["10.0.0.0/24"]
          destination_fqdns = ["time.windows.com"]
          protocols         = ["UDP"]
          destination_ports = ["123"]
        },
        {
          name              = "login windows.net"
          source_addresses  = ["10.0.0.0/24"]
          destination_fqdns = ["login.windows.net"]
          protocols         = ["TCP"]
          destination_ports = ["443"]
        },
        {
          name              = "msftconnecttest"
          source_addresses  = ["10.0.0.0/24"]
          destination_fqdns = ["www.msftconnecttest.com"]
          protocols         = ["TCP"]
          destination_ports = ["443"]
        }
      ]
    }]
    application_rule_collections = [{
      action   = "Allow"
      name     = "AVDOptionalApplicationRules"
      priority = 600
      rules = [
        {
          name                  = "Windows"
          source_addresses      = ["10.0.0.0/24"]
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
          source_addresses  = ["10.0.0.0/24"]
          destination_fqdns = ["*.events.data.microsoft.com"]
          protocols = [
            {
              port = 443
              type = "Https"
            }
          ]
        },
        {
          name              = "sfx"
          source_addresses  = ["10.0.0.0/24"]
          destination_fqdns = ["*.sfx.ms"]
          protocols = [
            {
              port = 443
              type = "Https"
            }
          ]
        },
        {
          name              = "digicert"
          source_addresses  = ["10.0.0.0/24"]
          destination_fqdns = ["*.digicert.com"]
          protocols = [
            {
              port = 443
              type = "Https"
            }
          ]
        },
        {
          name              = "Azure DNS"
          source_addresses  = ["10.0.0.0/24"]
          destination_fqdns = ["*.azure-dns.com", "*.azure-dns.net"]
          protocols = [
            {
              port = 443
              type = "Https"
            }
          ]
        }
      ]
    }]
  }

  m365 = {
    priority = 2000
    network_rule_collections = [{
      action   = "Allow"
      name     = "M365NetworkRules"
      priority = 500
      rules = [
        {
          name                  = "M365"
          source_addresses      = ["10.0.0.0/24"]
          destination_addresses = ["Office365.Common.Allow.Required"]
          protocols             = ["TCP"]
          destination_ports     = ["443"]
        }
      ]
    }]
  }

  internet = {
    priority = 3000
    network_rule_collections = [{
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
    }]
  }
}
