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
    Write-Host "Validating required PowerShell Modules: `n$($modules | Out-String)" -ForegroundColor Yellow
    $modules | Foreach-Object {
        if(!(Get-Module $PSItem -ListAvailable -ErrorAction Stop)){
            Write-Error "Module $PSItem Not found.. Install by running 'Install-Module $PSItem -Force -AllowClobber'"
        }
    }
    
    ## Check if Azure Network Manager Cmdlets are available in the 'Az.Network' Module
    Write-Host "Checking AzNetworkManager Cmdlets in the 'Az.Network' PowerShell module" -ForegroundColor Yellow
    if(!(Get-Command Get-AzNetworkManager -Module Az.Network)){
        Write-Error "Module 'Az.Network' Not found.. Update module by running 'Update-Module 'Az.Network' -Force'"
    }
}
catch {
    throw $PSItem.Exception.Message
}

$DeploymentName = "deployment-demo-avnm"

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

## Remove Demo Template (Takes about 15-20 minutes to complete)

Write-Host "Removing Resource Group [rg-demo-avnm]" -ForegroundColor Yellow
Remove-AzResourceGroup -Name "rg-demo-avnm" -Force -ErrorAction Stop

Write-Host "Removing Resource Group [rg-demo-alpha]" -ForegroundColor Yellow
Remove-AzResourceGroup -Name "rg-demo-alpha" -Force -ErrorAction Stop

Write-Host "Removing Resource Group [rg-demo-beta]" -ForegroundColor Yellow
Remove-AzResourceGroup -Name "rg-demo-beta" -Force -ErrorAction Stop

Write-Host "Removing Resource Group [rg-demo-hub]" -ForegroundColor Yellow
Remove-AzResourceGroup -Name "rg-demo-hub" -Force -ErrorAction Stop

Write-Host "Removing AVNM Policy Assignments at scope: Subscription[$SubscriptionId]" -ForegroundColor Yellow
Remove-AzPolicyAssignment -Name "[AVNM] pa-avnm-ng-alpha" -Scope "/subscriptions/$SubscriptionId" -ErrorAction Stop
Remove-AzPolicyAssignment -Name "[AVNM] pa-avnm-ng-beta" -Scope "/subscriptions/$SubscriptionId" -ErrorAction Stop
Remove-AzPolicyAssignment -Name "[AVNM] pa-avnm-ng-spokes" -Scope "/subscriptions/$SubscriptionId" -ErrorAction Stop

Write-Host "Removing AVNM Policy Definitions at scope: Subscription[$SubscriptionId]" -ForegroundColor Yellow
Remove-AzPolicyDefinition -Name "[AVNM] pd-avnm-ng-alpha" -SubscriptionId $SubscriptionId -Force -ErrorAction Stop
Remove-AzPolicyDefinition -Name "[AVNM] pd-avnm-ng-beta" -SubscriptionId $SubscriptionId -Force -ErrorAction Stop
Remove-AzPolicyDefinition -Name "[AVNM] pd-avnm-ng-spokes" -SubscriptionId $SubscriptionId -Force -ErrorAction Stop