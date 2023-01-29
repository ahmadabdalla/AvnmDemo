[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $SubscriptionId,

    [Parameter(Mandatory)]
    [string] $Location,

    [Parameter(Mandatory)]
    [PSCredential]$Credential
)


## Check Required Azure PowerShell Modules

try {
    $modules = @(
        'Az.Compute'
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

try {
    Write-Host "Deploying Demo VM [vm-hub].. ETA: 5 minutes" -ForegroundColor Yellow
    ## Hub VM
    New-AzVm `
        -ResourceGroupName 'rg-demo-hub' `
        -Name 'vm-hub' `
        -Location $Location `
        -VirtualNetworkName 'vnet-hub-demo' `
        -SubnetName 'sn-default-vnet-hub-demo' `
        -Credential $Credential `
        -Size 'Standard_B2s' `
        -PublicIpAddressName '' `
        -WarningAction SilentlyContinue
    
    Write-Host "Deploying Demo VM [vm-alpha-spoke].. ETA: 5 minutes" -ForegroundColor Yellow
    ## ALPHA Spoke VM
    New-AzVm `
        -ResourceGroupName 'rg-demo-alpha' `
        -Name 'vm-alpha-spoke' `
        -Location $Location `
        -VirtualNetworkName 'vnet-spoke-alpha' `
        -SubnetName 'sn-default-vnet-spoke-alpha' `
        -Credential $Credential `
        -Size 'Standard_B2s' `
        -PublicIpAddressName '' `
        -WarningAction SilentlyContinue

    Write-Host "Deploying Demo VM [vm-alpha-x].. ETA: 5 minutes" -ForegroundColor Yellow
    ## ALPHA X VM
    New-AzVm `
        -ResourceGroupName 'rg-demo-alpha' `
        -Name 'vm-alpha-x' `
        -Location $Location `
        -VirtualNetworkName 'vnet-x-alpha' `
        -SubnetName 'sn-default-vnet-x-alpha' `
        -Credential $Credential `
        -Size 'Standard_B2s' `
        -PublicIpAddressName '' `
        -WarningAction SilentlyContinue
}
catch {
    throw $PSItem.Exception.Message
}
finally {
    Get-AzVm -Status | Where-Object -Property ResourceGroupName -like "rg-demo-*" | Select-Object -Property Name, ResourceGroupName, ProvisioningState, PowerState | Format-Table
}


