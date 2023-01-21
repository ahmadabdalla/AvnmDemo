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
Deploy-AvnmDemo -TemplateFilePath 'main.deploy.bicep'

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
        'Az.Network'
        'Az.Compute'
    )

    $modules | Foreach-Object {
        if(!(Get-Module $PSItem -ErrorAction Stop)){
            Write-Error "Module $PSItem Not found.. Install by running 'Install-Module $PSItem -Force -AllowClobber'"
        }
    }
    
    ## Check if Azure Network Manager Cmdlets are available in the 'Az.Network' Module
    if(!(Get-Command Get-AzNetworkManager -Module Az.Network)){
        Write-Error "Module 'Az.Network' not up to date.. Update module by running 'Update-Module 'Az.Network' -Force'.. This is required to perform PowerShell tasks for the AVNM service in this lab."
    }
}
catch {
    throw $PSItem
}

## Connect To Azure

try {
    if ((Get-AzContext).Subscription.Id -ne $SubscriptionId) {
        Connect-AzAccount -SubscriptionId $SubscriptionId
    }  
}
catch {
    throw $PSItem
}

## Remove Demo Template (Takes about 15-20 minutes to complete)

Remove-AzResourceGroup -Name "rg-demo-avnm" -Force -ErrorAction Stop
Remove-AzResourceGroup -Name "rg-demo-alpha" -Force -ErrorAction Stop
Remove-AzResourceGroup -Name "rg-demo-beta" -Force -ErrorAction Stop
Remove-AzResourceGroup -Name "rg-demo-hub" -Force -ErrorAction Stop
Remove-AzPolicyAssignment -Name "[AVNM] pa-avnm-ng-alpha" -Scope "/subscriptions/$SubscriptionId" -ErrorAction Stop
Remove-AzPolicyAssignment -Name "[AVNM] pa-avnm-ng-beta" -Scope "/subscriptions/$SubscriptionId" -ErrorAction Stop
Remove-AzPolicyAssignment -Name "[AVNM] pa-avnm-ng-spokes" -Scope "/subscriptions/$SubscriptionId" -ErrorAction Stop
Remove-AzPolicyDefinition -Name "[AVNM] pd-avnm-ng-alpha" -SubscriptionId $SubscriptionId -Force -ErrorAction Stop
Remove-AzPolicyDefinition -Name "[AVNM] pd-avnm-ng-beta" -SubscriptionId $SubscriptionId -Force -ErrorAction Stop
Remove-AzPolicyDefinition -Name "[AVNM] pd-avnm-ng-spokes" -SubscriptionId $SubscriptionId -Force -ErrorAction Stop