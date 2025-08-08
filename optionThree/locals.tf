locals {
  # Rule templates - reusable rule definitions
  rule_templates = {
    # AVD Core Rules
    avd_core_rules = [
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
      },
      {
        name              = "mrglobalblob"
        destination_fqdns = ["mrsglobalsteus2prod.blob.core.windows.net"]
        protocols         = ["TCP"]
        destination_ports = ["443"]
      },
      {
        name              = "wvdportalstorageblob"
        destination_fqdns = ["wvdportalstorageblob.blob.core.windows.net"]
        protocols         = ["TCP"]
        destination_ports = ["443"]
      },
      {
        name              = "oneocsp"
        destination_fqdns = ["oneocsp.microsoft.com"]
        protocols         = ["TCP"]
        destination_ports = ["443"]
      },
      {
        name              = "microsoft.com"
        destination_fqdns = ["www.microsoft.com"]
        protocols         = ["TCP"]
        destination_ports = ["443"]
      }
    ]

    # AVD Optional Network Rules
    avd_optional_network_rules = [
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
      },
      {
        name              = "msftconnecttest"
        destination_fqdns = ["www.msftconnecttest.com"]
        protocols         = ["TCP"]
        destination_ports = ["443"]
      }
    ]

    # AVD Optional Application Rules
    avd_optional_application_rules = [
      {
        name                  = "Windows"
        destination_fqdn_tags = ["WindowsUpdate", "WindowsDiagnostics", "MicrosoftActiveProtectionService"]
        protocols = [{
          port = 443
          type = "Https"
        }]
      },
      {
        name              = "Events"
        destination_fqdns = ["*.events.data.microsoft.com"]
        protocols = [{
          port = 443
          type = "Https"
        }]
      },
      {
        name              = "sfx"
        destination_fqdns = ["*.sfx.ms"]
        protocols = [{
          port = 443
          type = "Https"
        }]
      },
      {
        name              = "digicert"
        destination_fqdns = ["*.digicert.com"]
        protocols = [{
          port = 443
          type = "Https"
        }]
      },
      {
        name              = "Azure DNS"
        destination_fqdns = ["*.azure-dns.com", "*.azure-dns.net"]
        protocols = [{
          port = 443
          type = "Https"
        }]
      }
    ]

    # M365 Rules
    m365_rules = [
      {
        name                  = "M365"
        destination_addresses = ["Office365.Common.Allow.Required"]
        protocols             = ["TCP"]
        destination_ports     = ["443"]
      }
    ]

    # Internet Rules
    internet_rules = [
      {
        name                  = "Internet"
        destination_addresses = ["*"]
        protocols             = ["TCP"]
        destination_ports     = ["443", "80"]
      }
    ]
  }

  # Rule collection configurations
  rule_collection_configs = {
    avd_core = {
      network_collections = [
        {
          action     = "Allow"
          name       = "AVDCoreNetworkRules"
          priority   = 500
          rules      = local.rule_templates.avd_core_rules
          source_subnet = var.network_segments.avd_subnet
        }
      ]
    }

    avd_optional = {
      network_collections = [
        {
          action     = "Allow"
          name       = "AVDOptionalNetworkRules"
          priority   = 500
          rules      = local.rule_templates.avd_optional_network_rules
          source_subnet = var.network_segments.general_subnet
        }
      ]
      application_collections = [
        {
          action     = "Allow"
          name       = "AVDOptionalApplicationRules"
          priority   = 600
          rules      = local.rule_templates.avd_optional_application_rules
          source_subnet = var.network_segments.general_subnet
        }
      ]
    }

    m365 = {
      network_collections = [
        {
          action     = "Allow"
          name       = "M365NetworkRules"
          priority   = 500
          rules      = local.rule_templates.m365_rules
          source_subnet = var.network_segments.general_subnet
        }
      ]
    }

    internet = {
      network_collections = [
        {
          action     = "Allow"
          name       = "InternetNetworkRules"
          priority   = 500
          rules      = local.rule_templates.internet_rules
          source_subnet = var.network_segments.general_subnet
        }
      ]
    }
  }

  # Build final configuration for enabled rule sets
  enabled_rule_collections = {
    for rule_set in var.enabled_rule_sets : rule_set => {
      priority = var.rule_collection_group_priorities[rule_set]
      config   = local.rule_collection_configs[rule_set]
    }
  }
}
