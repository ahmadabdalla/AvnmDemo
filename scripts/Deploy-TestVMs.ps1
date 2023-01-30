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

$VmProfiles = @(
    @{
        ## Hub VM
        ResourceGroupName  = 'rg-demo-hub'
        Name               = 'vm-hub'
        VirtualNetworkName = 'vnet-hub-demo'
        SubnetName         = 'sn-default-vnet-hub-demo'
    }
    @{
        ## ALPHA Spoke VM
        ResourceGroupName  = 'rg-demo-alpha'
        Name               = 'vm-alpha-spoke'
        VirtualNetworkName = 'vnet-spoke-alpha'
        SubnetName         = 'sn-default-vnet-spoke-alpha'
    }
    @{
        ## ALPHA X VM
        ResourceGroupName  = 'rg-demo-alpha'
        Name               = 'vm-alpha-x'
        VirtualNetworkName = 'vnet-x-alpha'
        SubnetName         = 'sn-default-vnet-x-alpha'
    }
)

Write-Host "Deploying Demo VMs. ETA: 5 minutes" -ForegroundColor Yellow
$VmProfiles | Foreach-Object -ThrottleLimit 5 -Parallel {
    New-AzVm `
        -ResourceGroupName $PSItem.ResourceGroupName `
        -Name $PSItem.Name `
        -Location $USING:Location `
        -VirtualNetworkName $PSItem.VirtualNetworkName `
        -SubnetName $PSItem.SubnetName `
        -Credential $USING:Credential `
        -Size 'Standard_B2s' `
        -PublicIpAddressName '' `
        -WarningAction SilentlyContinue

    $Nic = Get-AzNetworkInterface -Name $PSItem.Name -ResourceGroupName $PSItem.ResourceGroupName -WarningAction SilentlyContinue
    $Nic.NetworkSecurityGroup = $null
    Set-AzNetworkInterface -NetworkInterface $Nic -WarningAction SilentlyContinue | Out-Null
    Get-AzNetworkSecurityGroup -Name $PSItem.Name -ResourceGroupName $PSItem.ResourceGroupName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Remove-AzNetworkSecurityGroup -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}

Get-AzVm -Status | Where-Object -Property ResourceGroupName -like "rg-demo-*" | Select-Object -Property Name, ResourceGroupName, ProvisioningState, PowerState | Format-Table

