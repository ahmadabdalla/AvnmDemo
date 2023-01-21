

$SubscriptionId = '12345678-1234-1234-1234-123456789012' ###### CHANGE ME ######
$Location = 'australiaeast' ###### CHANGE ME (OPTIONAL) ######

#region ####### PART 1 - Creating the AVNM Demo Environment (15 minutes) ######

. .\scripts\Deploy-AvnmDemo.ps1 -SubscriptionId $SubscriptionId -Location $Location -ErrorAction Stop

#endregion
 

#region ####### PART 2 - Create Demo Virtual Machines in the environment ######

$Credential = Get-Credential

## Hub VM
New-AzVm `
    -ResourceGroupName 'rg-demo-hub' `
    -Name 'vm-hub' `
    -Location $Location `
    -VirtualNetworkName 'vnet-hub-demo' `
    -SubnetName 'sn-default-vnet-hub-demo' `
    -Credential $Credential `
    -Size 'Standard_B2s' `
    -AsJob

## ALPHA Spoke VM
New-AzVm `
    -ResourceGroupName 'rg-demo-alpha' `
    -Name 'vm-alpha-spoke' `
    -Location $Location `
    -VirtualNetworkName 'vnet-spoke-alpha' `
    -SubnetName 'sn-default-vnet-spoke-alpha' `
    -Credential $Credential `
    -Size 'Standard_B2s' `
    -AsJob

## ALPHA X VM
New-AzVm `
    -ResourceGroupName 'rg-demo-alpha' `
    -Name 'vm-alpha-x' `
    -Location $Location `
    -VirtualNetworkName 'vnet-x-alpha' `
    -SubnetName 'sn-default-vnet-x-alpha' `
    -Credential $Credential `
    -Size 'Standard_B2s' `
    -AsJob

# Wait for 5 minutes for the virtual machines to be created.
# TO see the Virtual machines status using PowerShell, ensure you have the latest 'Az.Compute' PowerShell module installed with at least version (5.1.1). Execute the following:
# You can also install the modules by running (Install-Module Az.Network -Force -AllowClobber)

Get-AzVm -Status | Where-Object -Property ResourceGroupName -like "rg-demo-*" | Select-Object -Property Name, PowerState 

#endregion


#region ####### PART 3 - Validating connectivity to the Hub virtual machine ######

# 1. Go to the Azure Portal
# 2. Search for the Hub VM 'vm-hub'
# 3. Click on 'Connect', and then select 'Bastion'
# 4. Input the Username and Password you configured in Part (2) of the Lab.
# 5. You should have a new Tab opened with an RDP session into the 'vm-hub' using Azure Bastion.

#endregion

#region ####### PART 4 - Validating NO connectivity to the spoke virtual machine ######

# 1. Go to the Azure Portal
# 2. Search for the Spoke Alpha VM 'vm-alpha-spoke'
# 3. Click on 'Connect', and then select 'Bastion'
# 4. Notice it does NOT give you a Bastion option. The reason there is no line of sight (i.e. vnet peering) from the VM to an Azure Bastion instance.

#endregion

#region ####### PART 5 - Deploying AVNM Connectivity Configuration for Hub Spoke and Mesh ######

# 1. Go to the Azure Portal
# 2. Search for the Virtual Network Manager 'avnm-demo'
# 3. From the blade menu, click on 'Configurations'
# 4. Select the 3 connectivity configurations options as below: 
    # - config-connectivity-HubSpoke-vnets ==> Deploys Hub-Spoke topology between the Hub VNET and the Spoke VNETs
    # - config-connectivity-alpha-vnets ==> Deploys a Mesh topology for all 'alpha' VNETs
    # - config-connectivity-beta-vnets ==> Deploys a Mesh topology for all 'beta' VNETs

# 5. Click on 'Deploy'
# 6. In the Deploy menu, select the 'Target Regions' as your location for deployment (i.e. australiaeast) and then click 'Next'
# 7. Notice the following:
    # - Existing configurations are empty, which represents the current state of your environment efore deployment.
    # - Goal state are showing 3 'Add' configurations, which represents the target state of your environment after deployment.
# 8. Now click on 'Deploy'. This will submit a deployment to AVNM to create your connectivity goal state.

# TO perform these steps using PowerShell, ensure you have the latest 'Az.Network' PowerShell module installed with at least version (5.1.2). Execute the following:

# You can also install the modules by running (Install-Module Az.Network -Force -AllowClobber)

$NetworkManagerName = 'avnm-demo'
$NetworkManagerResourceGroupName = 'rg-demo-avnm'

$ConnectivityConfigurations = Get-AzNetworkManagerConnectivityConfiguration `
    -NetworkManagerName $NetworkManagerName `
    -ResourceGroupName $NetworkManagerResourceGroupName

Deploy-AzNetworkManagerCommit -CommitType 'Connectivity' `
    -ConfigurationId $ConnectivityConfigurations.Id `
    -Name $NetworkManagerName `
    -ResourceGroupName $NetworkManagerResourceGroupName `
    -TargetLocation $Location

#endregion

# 9. To validate the deployment status of the connectivity configuration, select 'Deployments's from the settings menu in the AVNM blade.
# 10. Notice there are 3 connectvity deployments that were triggered, and notice the status of the 'deployment'.
# 11. To get the deployment status of the configuration, you can run the following:
    
    Get-AzNetworkManagerDeploymentStatus -NetworkManagerName $NetworkManagerName `
        -ResourceGroupName $NetworkManagerResourceGroupName `
        -Region $Location `
        -DeploymentType 'connectivity' | 
        Select-Object -ExpandProperty Value | 
        Select-Object -Property CommitTime, Region, DeploymentStatus, DeploymentType

# 12. To validate the active connectivity configuration for the environment, you can run the following:
    
    Get-AzNetworkManagerActiveConnectivityConfiguration -NetworkManagerName $NetworkManagerName `
        -ResourceGroupName $NetworkManagerResourceGroupName `
        -Region $Location | 
        Select-Object -ExpandProperty Value | 
        ForEach-Object {$PSItem | Select-Object -Property Description, ConnectivityTopology, ProvisioningState}

#endregion

#region ####### PART 6 - Verify Bastion connectivity to the spoke virtual machine ######

# 1. Go to the Azure Portal
# 2. Search for the Hub VM 'vm-alpha-spoke'
# 3. Click on 'Connect', and then select 'Bastion'
# 4. Input the Username and Password you configured in Part (2) of the Lab.
# 5. You should have a new Tab opened with an RDP session into the 'vm-spoke-alpha' using Azure Bastion.

# ==> Notice that now there is connectivity established between the hub and the spoke using the AVNM Hub-Spoke topology connectivity configuration.

# You can also check the status of the peering by using PowerShell:

    Get-AzVirtualNetworkPeering -VirtualNetworkName 'vnet-hub-demo' -ResourceGroupName 'rg-demo-hub' | Select-Object -Property Name, VirtualNetworkName, PeeringState 
    Get-AzVirtualNetworkPeering -VirtualNetworkName 'vnet-spoke-alpha' -ResourceGroupName 'rg-demo-alpha' | Select-Object -Property Name, VirtualNetworkName, PeeringState  

# Hub-Spoke Connectivity Configuration in AVNM uses the standard Virtual Network Peering technology.

#endregion

#region ####### PART 7 - Verify RDP connectivity from the Spoke VM to another VNET in the same Alpha Group ######

# 1. Use the same Bastion RDP session that was previously established in Part (6) to the spoke VM 'vm-alpha-spoke'
# 2. Once you are inside the spoke VM 'vm-alpha-spoke', we need to establish another RDP session into the virtual machine 'vm-alpha-x'
# 3. You can retrieve the IP address for the virtual machine either from the Virtual machine blade in the Azure Portal, or by running:

    $Vm_AlphaX_NetworkProfile_Id = (Get-Azvm -Name 'vm-alpha-x' -ResourceGroupName 'rg-demo-alpha').NetworkProfile.NetworkInterfaces[0].Id
    (Get-AzNetworkInterface -ResourceId $Vm_AlphaX_NetworkProfile_Id).IpConfigurations.PrivateIpAddress

# 4. Establish an RDP session to the IP Address that you fetched above.
# 5. Input the Username and Password you configured in Part (2) of the Lab.
# 6. You should be able establish an RDP session into the virtual machine 'vm-alpha-x' from the 'vm-alpha-spoke' virtual machine.

# This connectivity was achieved using the Mesh Connectivity Configuration in AVNM. It uses the new 'Connected Group' Construct which is different
    # from Hub-Spoke. 

# 7. Let us see the effective route table for the network interface for the virtual machine 'vm-alpha-x'. Using the below PowerShell command:

Get-AzEffectiveRouteTable -NetworkInterfaceName $Vm_AlphaX_NetworkProfile_Id.Split('/')[-1] -ResourceGroupName 'rg-demo-alpha' | 
    Where-Object -Property NextHopType -NE 'None' | 
    Select-Object -Property NextHopType, AddressPrefix, State

    # Notice here that there are three entries:
        # - VnetLocal ==> Represents the Address Prefix of the virtual network
        # - ConnectedGroup ==> Represents the AVNM Mesh VNet address prefixes. In this case, it is the virtual networks 'vnet-spoke-alpha' and 'vnet-alpha-y'
        # - Internet ==> Standard route table entry for internet traffic

# 8. Similarly, let us see the effective route table for the network interface for the virtual machine 'vm-alpha-spoke'. Using the the below PowerShell command:

$Vm_AlphaSpoke_NetworkProfile_Id = (Get-Azvm -Name 'vm-alpha-spoke' -ResourceGroupName 'rg-demo-alpha').NetworkProfile.NetworkInterfaces[0].Id
Get-AzEffectiveRouteTable -NetworkInterfaceName $Vm_AlphaSpoke_NetworkProfile_Id.Split('/')[-1] -ResourceGroupName 'rg-demo-alpha' | 
    Where-Object -Property NextHopType -NE 'None' |  
    Select-Object -Property NextHopType, AddressPrefix, State

    # Notice here that there are four entries:
        # - VnetLocal ==> Represents the Address Prefix of the virtual network
        # - VNetPeering ==> Represents the AVNM Hub-Spoke configuration. In this case, it is the hub virtual network 'vnet-hub'
        # - ConnectedGroup ==> Represents the AVNM Mesh VNet address prefixes. In this case, it is the virtual networks 'vnet-alpha-x' and 'vnet-alpha-y'
        # - Internet ==> Standard route table entry for internet traffic

#endregion

#region ####### PART 8 - Changing the Bastion inbound rule on the NSG to deny for spoke virtual networks ######

# In this exercise, we will block the bastion from being able to connect to the spoke virtual networks. This will be done on the NSG level of the spoke VNets.

# 1. Go to the Azure Portal
# 2. Search for the virtual machine 'vm-spoke-alpha'
# 3. Click on 'Connect', and then select 'Bastion'
# 4. Input the Username and Password you configured in Part (2) of the Lab.
# 5. You should have a new Tab opened with an RDP session into the 'vm-spoke-alpha' using Azure Bastion.
# 6. From the Azure Portal, now search for the NSG 'nsg-sn-default-vnet-spoke-alpha'
# 7. Let us add a block rule to this NSG on port 3389 from any source. Click on the 'Inbound Rules' section from the NSG blade. And select 'Add'.
# 8. Create the rule as following:
    #- Source: Any
    #- Source Port ranges: *
    #- Destination: Any
    #- Service: Custom
    #- Destination Port ranges: 3389
    #- Protocol: Any
    #- Action: Deny
    #- Priority: 100
    #- Name: Deny_RDP_Into_the_Subnet_from_Any

    # You can also enable this rule using PowerShell by running:
        $NSG = Get-AzNetworkSecurityGroup -Name 'nsg-sn-default-vnet-spoke-alpha' -ResourceGroupName 'rg-demo-alpha'
        Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG `
            -Name 'Deny_RDP_Into_the_Subnet_from_Any' `
            -Protocol '*' `
            -SourcePortRange '*' `
            -DestinationPortRange '3389' `
            -SourceAddressPrefix '*' `
            -DestinationAddressPrefix '*' `
            -Direction 'Inbound' `
            -Priority 100 `
            -Access 'Deny' |
        Set-AzNetworkSecurityGroup

# 9. After a couple of minutes, try logging into the same spoke virtual machine 'vm-spoke-alpha' using Bastion. Notice that the connection can no longer be established.

# Note: The next exercise will fix this using Azure Virtual Network Manager Security Admin Rules 

#endregion

#region ####### PART 9 - Deploying AVNM Security Admin Rules that apply rules on the 'spoke' network group ######

# In this exercise, we will override the rule we just deployed in Part (9) with an overarching admin rule that can bypass deny rules using AVNM Security Admin Rules.
# In the AVNM security configuration in code, there is a rule collection that is configured for the 'spoke' network group. This contains a rule that has an 'Always Allow' effect.

# 1. Go to the Azure Portal
# 2. Search for the Virtual Network Manager 'avnm-demo'
# 3. From the blade menu, click on 'Configurations'
# 4. Select the security admin configuration 'config-security-spokes' 
# 5. Select the 'Rule Collections' option from the settings from the left blade.
# 6. Notice there is one Rule collection which is pointing to the 'spokes' network group.
# 7. If you click on this rule collection, Notice we have one rule configured, which always allows RDP into the spokes from the Azure Bastion IP range.
    # This rule will override the 'Deny' rule enforced by the NSG for that virtual network. You can learn more about the rule types in the AVNM documentation.
# 8. If you navigate back to the Security Admin configuration menu, then
# 9. Click on 'Deploy'
# 10. In the Deploy menu, select the 'Target Regions' as your location for deployment (i.e. australiaeast) and then click 'Next'
# 11. Notice the following:
    # - Existing configurations are empty, which represents the current state of your environment efore deployment.
    # - Goal state are showing 1 'Add' configurations, which represents the target state of your environment after deployment.
# 12. Now click on 'Deploy'. This will submit a deployment to AVNM to create your security admin rules goal state.

# TO perform these steps using PowerShell, ensure you have the latest 'Az.Network' PowerShell module installed with at least version (5.1.2). Execute the following:

# You can also install the modules by running (Install-Module Az.Network -Force -AllowClobber)

$NetworkManagerName = 'avnm-demo'
$NetworkManagerResourceGroupName = 'rg-demo-avnm'

$SecurityAdminConfigurations = Get-AzNetworkManagerSecurityAdminConfiguration `
    -NetworkManagerName $NetworkManagerName `
    -ResourceGroupName $NetworkManagerResourceGroupName

Deploy-AzNetworkManagerCommit -CommitType 'SecurityAdmin' `
    -ConfigurationId $SecurityAdminConfigurations.Id `
    -Name $NetworkManagerName `
    -ResourceGroupName $NetworkManagerResourceGroupName `
    -TargetLocation $Location

# 13. To get the deployment status of the configuration, you can run the following:

Get-AzNetworkManagerDeploymentStatus -NetworkManagerName $NetworkManagerName `
    -ResourceGroupName $NetworkManagerResourceGroupName `
    -Region $Location `
    -DeploymentType 'securityAdmin' | 
    Select-Object -ExpandProperty Value | 
    Select-Object -Property CommitTime, Region, DeploymentStatus, DeploymentType

# 14. To validate the security admin rules that impacting the hub virtual network, you can run the following:
    Get-AzNetworkManagerEffectiveSecurityAdminRule -VirtualNetworkName 'vnet-spoke-alpha' -VirtualNetworkResourceGroupName 'rg-demo-alpha'
    # This will return the Security Admin Rule Resource ID that is effecting the virtual network. You can apply this to both the hub and spoke virtual networks to see the result

#endregion

#region ####### PART 10 - Verify Bastion connectivity to the spoke virtual machine ######

# 1. Go to the Azure Portal
# 2. Search for the Hub VM 'vm-alpha-spoke'
# 3. Click on 'Connect', and then select 'Bastion'
# 4. Input the Username and Password you configured in Part (2) of the Lab.
# 5. You should have a new Tab opened with an RDP session into the 'vm-spoke-alpha' using Azure Bastion.

# ==> Notice that now there is connectivity established to the spoke virtual machine via Azure Bastion, although the NSG rule is denying it.. 
    # That is because AVNM Always Allow rules supersede NSG rules, and the matching rule does not get delivered to the NSG.

#endregion

#region ####### PART 11 - Decomissioning the lab environment ######

# 1. To delete the lab environment. Run the following in PowerShell:

    . .\Remove-AvnmDemo.ps1 -SubscriptionId $SubscriptionId -ErrorAction Stop

    # This will delete the AVNM Azure Policies, and related resource groups used in this lab.

#endregion