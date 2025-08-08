# PowerShell script to validate firewall rules YAML files
param(
    [Parameter(Mandatory=$true)]
    [string]$YamlFile
)

function Test-YamlStructure {
    param([hashtable]$Config)
    
    $errors = @()
    
    foreach ($groupName in $Config.Keys) {
        $group = $Config[$groupName]
        
        # Check required fields
        if (-not $group.priority) {
            $errors += "Group '$groupName': Missing priority"
        }
        
        # Validate network rule collections
        if ($group.network_rule_collections) {
            foreach ($collection in $group.network_rule_collections) {
                if (-not $collection.action -or -not $collection.name -or -not $collection.priority) {
                    $errors += "Group '$groupName': Network collection missing required fields (action, name, priority)"
                }
                
                foreach ($rule in $collection.rules) {
                    if (-not $rule.name -or -not $rule.protocols -or -not $rule.destination_ports) {
                        $errors += "Group '$groupName': Network rule '$($rule.name)' missing required fields"
                    }
                    
                    if (-not $rule.destination_fqdns -and -not $rule.destination_addresses) {
                        $errors += "Group '$groupName': Network rule '$($rule.name)' must have either destination_fqdns or destination_addresses"
                    }
                }
            }
        }
        
        # Validate application rule collections
        if ($group.application_rule_collections) {
            foreach ($collection in $group.application_rule_collections) {
                if (-not $collection.action -or -not $collection.name -or -not $collection.priority) {
                    $errors += "Group '$groupName': Application collection missing required fields (action, name, priority)"
                }
                
                foreach ($rule in $collection.rules) {
                    if (-not $rule.name -or -not $rule.protocols) {
                        $errors += "Group '$groupName': Application rule '$($rule.name)' missing required fields"
                    }
                    
                    if (-not $rule.destination_fqdns -and -not $rule.destination_fqdn_tags) {
                        $errors += "Group '$groupName': Application rule '$($rule.name)' must have either destination_fqdns or destination_fqdn_tags"
                    }
                }
            }
        }
    }
    
    return $errors
}

try {
    Write-Host "Validating YAML file: $YamlFile" -ForegroundColor Green
    
    # Check if file exists
    if (-not (Test-Path $YamlFile)) {
        Write-Host "ERROR: File '$YamlFile' not found!" -ForegroundColor Red
        exit 1
    }
    
    # Load and parse YAML (requires powershell-yaml module)
    if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
        Write-Host "Installing powershell-yaml module..." -ForegroundColor Yellow
        Install-Module -Name powershell-yaml -Force -Scope CurrentUser
    }
    
    Import-Module powershell-yaml
    $yamlContent = Get-Content $YamlFile -Raw
    $config = ConvertFrom-Yaml $yamlContent
    
    # Validate structure
    $validationErrors = Test-YamlStructure $config
    
    if ($validationErrors.Count -eq 0) {
        Write-Host "✅ YAML validation passed!" -ForegroundColor Green
        Write-Host "Found $($config.Keys.Count) rule collection groups:" -ForegroundColor Cyan
        
        foreach ($groupName in $config.Keys) {
            $group = $config[$groupName]
            $networkCollections = if ($group.network_rule_collections) { $group.network_rule_collections.Count } else { 0 }
            $appCollections = if ($group.application_rule_collections) { $group.application_rule_collections.Count } else { 0 }
            
            Write-Host "  - $groupName (Priority: $($group.priority), Network: $networkCollections, App: $appCollections)" -ForegroundColor White
        }
    } else {
        Write-Host "❌ YAML validation failed with errors:" -ForegroundColor Red
        foreach ($error in $validationErrors) {
            Write-Host "  - $error" -ForegroundColor Red
        }
        exit 1
    }
    
} catch {
    Write-Host "ERROR: Failed to parse YAML file: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
