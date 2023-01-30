<#
.SYNOPSIS
Deploys the Azure Virtual Network Manager (AVNM) Demo Environment.

.DESCRIPTION
Deploys the Azure Virtual Network Manager (AVNM) Demo Environment.

.PARAMETER SubscriptionId
Mandatory. The subscription ID to deploy the demo into.

.PARAMETER Location
Mandatory. The location to deploy the demo into.

.EXAMPLE
Remove-AvnmDemo -SubscriptionId '12345678-1234-1234-1234567890123'

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $SubscriptionId
)

## Check Required Azure PowerShell Modules
try {
    $modules = @(
        'Az.Accounts'
        'Az.Resources'
    )
    Write-Host "Validating required PowerShell Modules: `n$($modules | Out-String)" -ForegroundColor Yellow
    $modules | Foreach-Object {
        if (!(Get-Module $PSItem -ListAvailable -ErrorAction Stop)) {
            Write-Error "Module $PSItem Not found.. Install by running 'Install-Module $PSItem -Force -AllowClobber'"
        }
    }
}
catch {
    throw $PSItem.Exception.Message
}

## Connect To Azure
try {
    Write-Host "Validating Azure context for Subscription ID: [$SubscriptionId]" -ForegroundColor Yellow
    if ((Get-AzContext).Subscription.Id -ne $SubscriptionId) {
        Write-Host "Connecting to Azure and setting context for Subscription ID: [$SubscriptionId]" -ForegroundColor Yellow
        Connect-AzAccount -SubscriptionId $SubscriptionId
    } 
}
catch {
    throw $PSItem.Exception.Message
}

## Remove AVNM Resource Group and Resources
Write-Host "Removing Resource Group [rg-demo-avnm] and Policy Resources. ETA: 5 minutes" -ForegroundColor Yellow

if ($null -ne (Get-AzResourceGroup -Name "rg-demo-avnm" -WarningAction SilentlyContinue)) {
    
    Remove-AzResourceGroup -Name "rg-demo-avnm" -Force -ErrorAction Stop -WarningAction SilentlyContinue

    ## Remove AVNM Policy Assignments
    Write-Host "Removing AVNM Policy Assignments at scope: Subscription[$SubscriptionId]. ETA: 1 minute" -ForegroundColor Yellow
    $PolicyAssignmentNames = @(
        '[AVNM] pa-avnm-ng-alpha'
        '[AVNM] pa-avnm-ng-beta'
        '[AVNM] pa-avnm-ng-spokes'
    )

    $PolicyAssignmentNames | Foreach-Object -ThrottleLimit 5 -Parallel {
        if ($null -ne (Get-AzPolicyAssignment -Name $PSItem -Scope "/subscriptions/$USING:SubscriptionId" -WarningAction SilentlyContinue)) {
            Remove-AzPolicyAssignment -Name $PSItem -Scope "/subscriptions/$USING:SubscriptionId" -ErrorAction Stop -WarningAction SilentlyContinue
        }
    }

    ## Remove AVNM Policy Definitions
    Write-Host "Removing AVNM Policy Definitions at scope: Subscription[$SubscriptionId]. ETA: 1 minute" -ForegroundColor Yellow
    $PolicyDefinitionsNames = @(
        '[AVNM] pd-avnm-ng-alpha'
        '[AVNM] pd-avnm-ng-beta'
        '[AVNM] pd-avnm-ng-spokes'
    )

    $PolicyDefinitionsNames | Foreach-Object -ThrottleLimit 5 -Parallel {
        if ($null -ne (Get-AzPolicyDefinition -Name $PSItem -SubscriptionId $USING:SubscriptionId -WarningAction SilentlyContinue)) {
            Remove-AzPolicyDefinition -Name $PSItem -SubscriptionId $USING:SubscriptionId -Force -ErrorAction Stop -WarningAction SilentlyContinue
        }
    }

}

# Remove Remaining Resource Groups
$ResourceGroupNames = @(
    'rg-demo-alpha'
    'rg-demo-beta'
    'rg-demo-hub'
)

$ResourceGroupNames | Foreach-Object -ThrottleLimit 5 -Parallel {
    Write-Host "Removing Resource Group [$PSItem]. ETA: 5-10 minutes" -ForegroundColor Yellow
    if ($null -ne (Get-AzResourceGroup -Name $PSItem)) {
        Remove-AzResourceGroup -Name $PSItem -Force -ErrorAction Stop -WarningAction SilentlyContinue
    }
}