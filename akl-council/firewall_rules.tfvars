# firewall_rules.tfvars
# ─────────────────────────────────────────────────────────────────────────────
# Managed by: Network / Security team
# Deploy with: terraform apply -var-file="terraform.tfvars" \
#                               -var-file="firewall_rules.tfvars"
#
# Each top-level key becomes a separate Rule Collection Group on the Firewall Policy.
# source_ip_group_keys / destination_ip_group_keys reference the IP group keys built
# from the stamps variable:  "<stamp>-test" | "<stamp>-preprod" | "<stamp>-prod" | "<stamp>-identity"
# Available stamp keys:  aklc  |  gss  |  wsl
#
# Rule Collection Group priority guidance:
#   1000-1999  Infrastructure / east-west / identity
#   2000-2999  Workload / AVD
#   3000-3999  Workload egress (reserved)
#   4000-4999  DNAT / inbound (reserved)
#   65000      Default deny (implicit - no explicit RCG needed)
# ─────────────────────────────────────────────────────────────────────────────

firewall_rules = {

  # ───────────────────────────────────────────────────────────────────────────
  # infra  (priority 1000)
  #   - East-west: workload VNets ↔ identity spoke (AD / domain services)
  #   - Identity egress: NTP, Entra Cloud Sync
  #
  # AD port reference: https://learn.microsoft.com/en-us/troubleshoot/windows-server/
  #                    active-directory/config-firewall-for-ad-domains-and-trusts
  # ───────────────────────────────────────────────────────────────────────────

  infra = {
    priority = 1000

    network_collections = [

      # ── East-west: workload → identity ──────────────────────────────────────
      {
        name     = "EastWest-WorkloadToIdentity"
        priority = 100
        action   = "Allow"
        rules = [

          # TCP: all ports open during build mode (tighten post-build)
          {
            name                      = "aklc-Workload-to-Identity-TCP"
            source_ip_group_keys      = ["aklc-test", "aklc-preprod", "aklc-prod"]
            destination_ip_group_keys = ["aklc-identity"]
            protocols                 = ["TCP"]
            destination_ports         = ["*"]
          },
          {
            name                      = "gss-Workload-to-Identity-TCP"
            source_ip_group_keys      = ["gss-test", "gss-preprod", "gss-prod"]
            destination_ip_group_keys = ["gss-identity"]
            protocols                 = ["TCP"]
            destination_ports         = ["*"]
          },
          {
            name                      = "wsl-Workload-to-Identity-TCP"
            source_ip_group_keys      = ["wsl-test", "wsl-preprod", "wsl-prod"]
            destination_ip_group_keys = ["wsl-identity"]
            protocols                 = ["TCP"]
            destination_ports         = ["*"]
          },

          # UDP: all ports open during build mode (tighten post-build)
          {
            name                      = "aklc-Workload-to-Identity-UDP"
            source_ip_group_keys      = ["aklc-test", "aklc-preprod", "aklc-prod"]
            destination_ip_group_keys = ["aklc-identity"]
            protocols                 = ["UDP"]
            destination_ports         = ["*"]
          },
          {
            name                      = "gss-Workload-to-Identity-UDP"
            source_ip_group_keys      = ["gss-test", "gss-preprod", "gss-prod"]
            destination_ip_group_keys = ["gss-identity"]
            protocols                 = ["UDP"]
            destination_ports         = ["*"]
          },
          {
            name                      = "wsl-Workload-to-Identity-UDP"
            source_ip_group_keys      = ["wsl-test", "wsl-preprod", "wsl-prod"]
            destination_ip_group_keys = ["wsl-identity"]
            protocols                 = ["UDP"]
            destination_ports         = ["*"]
          },
        ]
      },

      # ── East-west: identity → workload ──────────────────────────────────────
      # DC-initiated traffic: RPC callbacks, GP, SYSVOL, DNS responses
      {
        name     = "EastWest-IdentityToWorkload"
        priority = 200
        action   = "Allow"
        rules = [

          # TCP: RPC endpoint mapper, SMB (SYSVOL/NETLOGON), RPC dynamic range
          {
            name                      = "aklc-Identity-to-Workload-TCP"
            source_ip_group_keys      = ["aklc-identity"]
            destination_ip_group_keys = ["aklc-test", "aklc-preprod", "aklc-prod"]
            protocols                 = ["TCP"]
            destination_ports         = ["53", "135", "445", "49152-65535"]
          },
          {
            name                      = "gss-Identity-to-Workload-TCP"
            source_ip_group_keys      = ["gss-identity"]
            destination_ip_group_keys = ["gss-test", "gss-preprod", "gss-prod"]
            protocols                 = ["TCP"]
            destination_ports         = ["53", "135", "445", "49152-65535"]
          },
          {
            name                      = "wsl-Identity-to-Workload-TCP"
            source_ip_group_keys      = ["wsl-identity"]
            destination_ip_group_keys = ["wsl-test", "wsl-preprod", "wsl-prod"]
            protocols                 = ["TCP"]
            destination_ports         = ["53", "135", "445", "49152-65535"]
          },

          # UDP: DNS
          {
            name                      = "aklc-Identity-to-Workload-UDP"
            source_ip_group_keys      = ["aklc-identity"]
            destination_ip_group_keys = ["aklc-test", "aklc-preprod", "aklc-prod"]
            protocols                 = ["UDP"]
            destination_ports         = ["53"]
          },
          {
            name                      = "gss-Identity-to-Workload-UDP"
            source_ip_group_keys      = ["gss-identity"]
            destination_ip_group_keys = ["gss-test", "gss-preprod", "gss-prod"]
            protocols                 = ["UDP"]
            destination_ports         = ["53"]
          },
          {
            name                      = "wsl-Identity-to-Workload-UDP"
            source_ip_group_keys      = ["wsl-identity"]
            destination_ip_group_keys = ["wsl-test", "wsl-preprod", "wsl-prod"]
            protocols                 = ["UDP"]
            destination_ports         = ["53"]
          },
        ]
      },

      # ── Identity egress: NTP ─────────────────────────────────────────────────
      {
        name     = "Identity-NTP"
        priority = 300
        action   = "Allow"
        rules = [
          {
            name                 = "Identity-NTP-All-Stamps"
            source_ip_group_keys = ["aklc-identity", "gss-identity", "wsl-identity"]
            destination_fqdns    = ["time.windows.com"]
            protocols            = ["UDP"]
            destination_ports    = ["123"]
          },
        ]
      },
    ]

    application_collections = [

      # ── Identity egress: Entra Cloud Sync ────────────────────────────────────
      # Ref: https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/
      #      how-to-prerequisites#firewall-and-proxy-requirements
      {
        name     = "Identity-EntraCloudSync"
        priority = 400
        action   = "Allow"
        rules = [
          {
            name                 = "CloudSync-Required"
            source_ip_group_keys = ["aklc-identity", "gss-identity", "wsl-identity"]
            destination_fqdns = [
              "*.msappproxy.net",
              "*.servicebus.windows.net",
              "login.microsoftonline.com",
              "login.windows.net",
              "secure.aadcdn.microsoftonline-p.com",
              "*.microsoftonline.com",
              "graph.microsoft.com",
              "management.azure.com",
              "adminwebservice.microsoftonline.com",
            ]
            protocols = [
              { port = 443, type = "Https" },
            ]
          },
        ]
      },
    ]
  }

  # ───────────────────────────────────────────────────────────────────────────
  # avd  (priority 2000)
  #   Production workload IP groups only — AVD session hosts run in prod.
  #   All entries sourced from:
  #   https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint
  # ───────────────────────────────────────────────────────────────────────────

  avd = {
    priority = 2000

    network_collections = [

      {
        name     = "AVD-Network-Required"
        priority = 100
        action   = "Allow"
        rules = [

          # Azure service tags — covers the bulk of required TCP/443 endpoints.
          # WindowsVirtualDesktop: *.wvd.microsoft.com, *.service.windows.cloud.microsoft,
          #                        *.windows.cloud.microsoft, *.windows.static.microsoft,
          #                        wvdportalstorageblob.blob.core.windows.net + backend IPs
          {
            name                      = "AVD-ServiceTag-WVD"
            source_ip_group_keys      = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_addresses     = ["WindowsVirtualDesktop"]
            protocols                 = ["TCP"]
            destination_ports         = ["443"]
          },
          {
            name                      = "AVD-ServiceTag-AzureAD"
            source_ip_group_keys      = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_addresses     = ["AzureActiveDirectory"]
            protocols                 = ["TCP"]
            destination_ports         = ["443"]
          },
          {
            name                      = "AVD-ServiceTag-AzureMonitor"
            source_ip_group_keys      = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_addresses     = ["AzureMonitor"]
            protocols                 = ["TCP"]
            destination_ports         = ["443"]
          },
          # AzureCloud: covers catalogartifact.azureedge.net, mrsglobalsteus2prod.blob.core.windows.net
          {
            name                      = "AVD-ServiceTag-AzureCloud"
            source_ip_group_keys      = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_addresses     = ["AzureCloud"]
            protocols                 = ["TCP"]
            destination_ports         = ["443"]
          },

          # Relayed RDP (RDP Shortpath via TURN relay) — mandatory per MS docs
          {
            name                      = "AVD-RelayedRDP-Shortpath"
            source_ip_group_keys      = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_addresses     = ["51.5.0.0/16"]
            protocols                 = ["UDP"]
            destination_ports         = ["3478"]
          },

          # Windows KMS activation — TCP 1688 (not HTTP, must be a network rule)
          {
            name                      = "AVD-Windows-KMS"
            source_ip_group_keys      = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_fqdns         = ["azkms.core.windows.net"]
            protocols                 = ["TCP"]
            destination_ports         = ["1688"]
          },

          # Azure Instance Metadata Service + health monitoring probes
          {
            name                      = "AVD-IMDS-and-HealthMonitor"
            source_ip_group_keys      = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_addresses     = ["169.254.169.254", "168.63.129.16"]
            protocols                 = ["TCP"]
            destination_ports         = ["80"]
          },
        ]
      },

      # ── AVD management access: prod → lower environments (same stamp only) ────
      # Allows AVD users (sourced from prod VNet) to RDP/SSH/WinRM into VMs in
      # test and preprod. Per-stamp rules prevent cross-stamp lateral movement.
      {
        name     = "AVD-Management-Access"
        priority = 200
        action   = "Allow"
        rules = [
          {
            name                      = "aklc-AVD-Manage-Test"
            source_ip_group_keys      = ["aklc-prod"]
            destination_ip_group_keys = ["aklc-test"]
            protocols                 = ["TCP"]
            destination_ports         = ["22", "3389", "5985", "5986"]
          },
          {
            name                      = "aklc-AVD-Manage-Preprod"
            source_ip_group_keys      = ["aklc-prod"]
            destination_ip_group_keys = ["aklc-preprod"]
            protocols                 = ["TCP"]
            destination_ports         = ["22", "3389", "5985", "5986"]
          },
          {
            name                      = "gss-AVD-Manage-Test"
            source_ip_group_keys      = ["gss-prod"]
            destination_ip_group_keys = ["gss-test"]
            protocols                 = ["TCP"]
            destination_ports         = ["22", "3389", "5985", "5986"]
          },
          {
            name                      = "gss-AVD-Manage-Preprod"
            source_ip_group_keys      = ["gss-prod"]
            destination_ip_group_keys = ["gss-preprod"]
            protocols                 = ["TCP"]
            destination_ports         = ["22", "3389", "5985", "5986"]
          },
          {
            name                      = "wsl-AVD-Manage-Test"
            source_ip_group_keys      = ["wsl-prod"]
            destination_ip_group_keys = ["wsl-test"]
            protocols                 = ["TCP"]
            destination_ports         = ["22", "3389", "5985", "5986"]
          },
          {
            name                      = "wsl-AVD-Manage-Preprod"
            source_ip_group_keys      = ["wsl-prod"]
            destination_ip_group_keys = ["wsl-preprod"]
            protocols                 = ["TCP"]
            destination_ports         = ["22", "3389", "5985", "5986"]
          },
        ]
      },
    ]

    application_collections = [

      # Required: certificate validation endpoints (TCP 80)
      {
        name     = "AVD-Certs-Required"
        priority = 300
        action   = "Allow"
        rules = [
          {
            name                 = "AVD-CertValidation"
            source_ip_group_keys = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_fqdns = [
              "oneocsp.microsoft.com",
              "www.microsoft.com",
              "*.aikcertaia.microsoft.com",
              "azcsprodeusaikpublish.blob.core.windows.net",
              "*.microsoftaik.azure.net",
              "ctldl.windowsupdate.com",
            ]
            protocols = [
              { port = 80, type = "Http" },
            ]
          },
        ]
      },

      # Optional: Windows Update, diagnostics, telemetry
      {
        name     = "AVD-App-Optional"
        priority = 400
        action   = "Allow"
        rules = [
          {
            name                  = "AVD-WindowsUpdate"
            source_ip_group_keys  = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_fqdn_tags = ["WindowsUpdate", "WindowsDiagnostics"]
            protocols = [
              { port = 443, type = "Https" },
            ]
          },
          {
            name                 = "AVD-Optional-FQDNs"
            source_ip_group_keys = ["aklc-prod", "gss-prod", "wsl-prod"]
            destination_fqdns = [
              "login.windows.net",
              "*.events.data.microsoft.com",
            ]
            protocols = [
              { port = 443, type = "Https" },
            ]
          },
        ]
      },
    ]
  }

  # ───────────────────────────────────────────────────────────────────────────
  # workload_egress  (priority 3000)
  #   - Outbound HTTP/HTTPS from all workload VNets to the internet.
  #   - Wildcard FQDN (*) permits all internet destinations; tighten to specific
  #     FQDNs or web categories (Premium policy) once traffic patterns are known.
  # ───────────────────────────────────────────────────────────────────────────

  workload_egress = {
    priority = 3000

    application_collections = [

      # ── Workload → Internet (HTTP/HTTPS) ────────────────────────────────────
      {
        name     = "Workload-Internet-Egress"
        priority = 100
        action   = "Allow"
        rules = [
          {
            name                 = "AllWorkloads-Internet-HTTP"
            source_ip_group_keys = [
              "aklc-test", "aklc-preprod", "aklc-prod",
              "gss-test",  "gss-preprod",  "gss-prod",
              "wsl-test",  "wsl-preprod",  "wsl-prod",
            ]
            destination_fqdns = ["*"]
            protocols = [
              { port = 80,  type = "Http"  },
            ]
          },
          {
            name                 = "AllWorkloads-Internet-HTTPS"
            source_ip_group_keys = [
              "aklc-test", "aklc-preprod", "aklc-prod",
              "gss-test",  "gss-preprod",  "gss-prod",
              "wsl-test",  "wsl-preprod",  "wsl-prod",
            ]
            destination_fqdns = ["*"]
            protocols = [
              { port = 443, type = "Https" },
            ]
          },
        ]
      },
    ]
  }

}
