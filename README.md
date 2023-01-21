# Intro

This repository contains a demo implementation for [Azure Virtual Network Manager (AVNM)](https://learn.microsoft.com/en-us/azure/virtual-network-manager/overview) using Infrastructure as Code with [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep). The demo uses Bicep modules from [Common Azure Resources Modules Library (CARML)](https://aka.ms/carml) to provision the following design:

**PENDING DIAGRAM**

# Requirements

This demo requires the following:

## Azure Specific Knowledge

1. Assumes basic understanding of Microsoft Azure and [Azure Networking](https://learn.microsoft.com/en-us/azure/networking/azure-for-network-engineers?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json), specifically related to the following:
   1. [Subscriptions](https://learn.microsoft.com/en-us/microsoft-365/enterprise/subscriptions-licenses-accounts-and-tenants-for-microsoft-cloud-offerings?view=o365-worldwide#subscriptions)
   2. [Resource Groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group)
   3. [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
   4. [Virtual Machines](https://learn.microsoft.com/en-us/training/modules/create-windows-virtual-machine-in-azure/)
   5. [Virtual Networks](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
   6. [Virtual Network Peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
   7. [Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)
   8. [Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-group-how-it-works)
   9. [Routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)

2. [Azure Virtual Network Manager (AVNM)](https://learn.microsoft.com/en-us/azure/virtual-network-manager/overview) and the following features:
   1. [Network Groups](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-network-groups)
      1. [Dynamic Memberships using Azure Policy](https://learn.microsoft.com/en-us/azure/virtual-network-manager/how-to-exclude-elements)
   2. [Connectivity Configuration](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-connectivity-configuration#connectivity-configuration)
      1. [Hub Spoke Topology](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-connectivity-configuration#hub-and-spoke-topology)
      2. [Mesh Topology](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-connectivity-configuration#mesh-network-topology)
         1. [Connected Groups](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-connectivity-configuration#connectedgroup)
   3. [Security Admin Rules Configuration](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-security-admins)
      1. [Rules Enforcement Method](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-enforcement)
   4. [Deployments](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-deployments)

## Azure Engineering Specific Knowledge

1. [Network Manager Template Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networkmanagers)
2. [CARML - Azure Virtual Network Manager Bicep Module Readme](https://github.com/Azure/ResourceModules/tree/main/modules/Microsoft.Network/networkManagers)
3. [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep)
4. [IDE - Visual Studio Code](https://code.visualstudio.com/)
5. [Source Control - Git](https://git-scm.com/)
6. [Azure PowerShell](https://learn.microsoft.com/en-us/powershell/azure/what-is-azure-powershell?view=azps-9.3.0)


# Pre-requisites 

In order to implement the lab, the following is required:

- An [Azure Subscription](https://learn.microsoft.com/en-us/microsoft-365/enterprise/subscriptions-licenses-accounts-and-tenants-for-microsoft-cloud-offerings?view=o365-worldwide#subscriptions) for deploying and testing resources. If you do not have one, you can sign up to a free trial [here](https://azure.microsoft.com/en-us/free/).

- Permissions. Either options are required at the Subscription scope:
  - [Owner](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)
  - [Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor) and [Resource Policy Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#resource-policy-contributor).

- Visual Studio Code installed with the [Bicep Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)
- Azure CLI with the latest version of the [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli) or [Manual installation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#install-manually) of Bicep.
- Latest [Azure PowerShell](https://learn.microsoft.com/en-us/powershell/azure/what-is-azure-powershell?view=azps-9.3.0) modules:
  - Az.Accounts
  - Az.Resources
  - Az.Network
  - Az.Compute


# Repository Structure

The repo is structured in the following way:

- **Constructs**: Contains the Bicep configuration files for the demo.
- **Modules**: Contains the [Common Azure Resources Modules Library (CARML)](https://aka.ms/carml) modules used by the constructs (configuration files) to deploy the demo.
- **Scripts**: Contains scripts that supports the demo.
- [**Demo-Guide.ps1**](https://github.com/ahmadabdalla/AvnmDemo/blob/main/Deploy-AvnmDemo.ps1): Is a script that goes through the demo step by step.
- [**main.deploy.bicep**](https://github.com/ahmadabdalla/AvnmDemo/blob/main/main.deploy.bicep): Is the main Bicep file used to demo the demo.

# How to start the demo?

1. Clone this GitHub repository on your workstation. See this [GitHub guide](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) for more details.
2. Open Visual Studio Code on your workstation where the cloned repo is located.
3. Open the [Deploy-AvnmDemo.ps1](https://github.com/ahmadabdalla/AvnmDemo/blob/main/Deploy-AvnmDemo.ps1) from within VS Code.
4. The demo guide in this script should contain the required sequence of sections to successfully deploy and remove this lab.

# What is the demo deploying?

1. Resource Groups:
   1. AVNM Resource Group: Contains all resources for Azure Virtual Network Manager (AVNM).
   2. Hub Resource Group: Contains a hub virtual network, network security groups, Azure Bastion.
   3. Alpha Resource Group: Contains virtual networks allocated to a demo 'alpha' group.
   4. Beta Resource Group: Contains virtual networks allocated to a demo 'beta' group.
2. Hub Virtual Network with Azure Bastion: Used to connect to the spokes located in the 'alpha' and 'beta' resource groups.
3. Spoke Virtual Networks for the 'alpha' and 'beta' groups.
4. Extended 'child' Virtual Networks, for each of the 'alpha' and 'beta' groups, named as 'X' and 'Y'.
5. Azure Virtual Network Manager:
   1. Creating network groups as per the diagram and uses Azure Policy to create dynamic membership to these network groups.
   2. Creating connectivity configurations as per the diagram.
   3. Creating Security Admin Rules configurations.
6. Virtual machines in the Hub Virtual Network, the 'Alpha' Spoke Virtual Network and the 'X' extended Virtual Network for the 'alpha' group.
7. Changing the NSG rule for the Spoke virtual networks.

# Housekeeping

Although this demo uses technologies from Microsoft Azure, it is not affiliated to Microsoft, but rather a personal project contributing to the Azure community to learn how to use Azure Virtual Network Manager using Infrastructure as Code. Please read the services documentation regarding supported features and limitations. If you have issues using the modules referenced in this repository, please open an issue with the CARML team by going to [https://aka.ms/carml], and filing a new GitHub [issue](https://github.com/Azure/ResourceModules/issues). Everyone is welcomed to contribute to this repository by either raising issues or issuing pull requests for things that can be improved.

if you managed to get to the end of this document.. thank you for reading :) and I hope you enjoy this demo.




