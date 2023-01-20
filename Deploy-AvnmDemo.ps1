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
    [string] $SubscriptionId,

    [Parameter(Mandatory)]
    [string] $Location
)


## Check Required Azure PowerShell Modules

try {
    $modules = @(
        'Az.Accounts'
        'Az.Resources'
        'Az.Networks'
        'Az.Compute'
    )

    $modules | Foreach-Object {
        if(!(Get-Module $PSItem -ErrorAction Stop)){
            Write-Error "Module $PSItem Not found.. Install by running 'Install-Module $PSItem -Force -AllowClobber'"
        }
    }
    
    ## Check if Azure Network Manager Cmdlets are available in the 'Az.Network' Module
    if(!(Get-Command Get-AzNetworkManager -Module Az.Network)){
        Write-Error "Module 'Az.Network' Not found.. Update module by running 'Update-Module 'Az.Network' -Force'"
    }
}
catch {
    throw $PSItem
}

$DeploymentName = "deployment-demo-avnm"

## Connect To Azure

try {
    if ((Get-AzContext).Subscription.Id -ne $SubscriptionId) {
        Connect-AzAccount -SubscriptionId $SubscriptionId
    } 
}
catch {
    throw $PSItem
}

## Deploy Demo Template (Takes about 15-20 minutes to complete)

New-AzDeployment -Name $DeploymentName -Location $Location -TemplateFile 'main.deploy.bicep'


