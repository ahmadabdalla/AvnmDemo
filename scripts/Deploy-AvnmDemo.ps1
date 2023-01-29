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
Deploy-AvnmDemo -TemplateFilePath 'main.deploy.bicep' -Location 'australiaeast' -SubscriptionId '12345678-1234-1234-123456789012'

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $SubscriptionId,

    [Parameter(Mandatory)]
    [string] $Location,

    [Parameter(Mandatory)]
    [string] $TemplateFile
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

## Deploy Demo Template (Takes about 15-20 minutes to complete)
try {
    Write-Host "Deploying AVNM using template file [$TemplateFile] at location [$Location].. ETA: 10-15 minutes" -ForegroundColor Yellow
    New-AzDeployment -Name $DeploymentName -Location $Location -TemplateFile $TemplateFile -WarningAction SilentlyContinue
}
catch {
    throw $PSItem.Exception.Message
}



