# Azure Virtual Network Peering - Terraform Infrastructure

This Terraform project provisions a complete Azure infrastructure with **two peered virtual networks**, enabling secure cross-VNet communication between resources in different network segments.

## 📋 Overview

The infrastructure includes:
- **Resource Group**: Single container for all Azure resources
- **Two Virtual Networks**: Isolated networks with custom address spaces
- **Virtual Network Peering**: Bidirectional connectivity between VNets
- **Linux Virtual Machines**: Ubuntu VMs with nginx web servers
- **Network Security Groups**: Firewall rules for SSH and HTTP access
- **Public IP Addresses**: External access to VMs

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Resource Group (app-grp)                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────┐      ┌──────────────────────┐   │
│  │   app03-network      │◄────►│   test-network       │   │
│  │   10.0.0.0/16        │ Peer │   10.1.0.0/16        │   │
│  ├──────────────────────┤      ├──────────────────────┤   │
│  │ • Subnet             │      │ • Subnet             │   │
│  │ • NSG (SSH/HTTP)     │      │ • NSG (SSH/HTTP)     │   │
│  │ • Public IP          │      │ • Public IP          │   │
│  │ • Network Interface  │      │ • Network Interface  │   │
│  │ • Linux VM + nginx   │      │ • Linux VM + nginx   │   │
│  └──────────────────────┘      └──────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
Virtual Network Peering/
│
├── main.tf                          # Root module - orchestrates all resources
├── variables.tf                     # Variable declarations
├── terraform.tfvars                 # Configuration values
├── outputs.tf                       # (Optional) Output definitions
├── README.md                        # This file
│
└── modules/
    ├── general/
    │   └── resourcegroup/           # Resource group module
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    │
    ├── networking/
    │   ├── vnet/                    # Virtual network module
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   │
    │   └── vnetpeering/             # VNet peering module
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    │
    └── Compute/
        └── VirtualMachines/         # VM module
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── copyfiles.tf         # Post-deployment configuration
```

## 🚀 Quick Start

### Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **Terraform** installed (v1.0+)
3. **Azure CLI** installed and authenticated:
   ```powershell
   az login
   az account set --subscription "2ab4f266-3113-46c7-9a11-16bcb8ae5659"
   ```

### Deployment Steps

1. **Navigate to the project directory**:
   ```powershell
   cd "c:\Terraform\Virtual Network Peering"
   ```

2. **Initialize Terraform**:
   ```powershell
   terraform init
   ```

3. **Review the plan**:
   ```powershell
   terraform plan
   ```

4. **Apply the configuration**:
   ```powershell
   terraform apply
   ```
   Type `yes` when prompted.

5. **Access the VMs**:
   - After deployment completes (~5-6 minutes), retrieve public IPs from outputs
   - Access nginx web servers: `http://<public-ip>/Default.html`
   - SSH to VMs: `ssh adminuser@<public-ip>` (password: `Azure@1234`)

### Cleanup

```powershell
terraform destroy
```

## ⚙️ Configuration

### Environment Settings (terraform.tfvars)

```hcl
resource_group_name = "app-grp"
location = "UK South"

environment = {
  app03 = {
    vnet_name               = "app03-network"
    vnet_address_prefix     = "10.0.0.0/16"
    vm_count                = 1
    vnet_subnet_count       = 1
    network_interface_count = 1
    public_ip_address_count = 1
  }
  test = {
    vnet_name               = "test-network"
    vnet_address_prefix     = "10.1.0.0/16"
    vm_count                = 1
    vnet_subnet_count       = 1
    network_interface_count = 1
    public_ip_address_count = 1
  }
}

vnet_peering = {
  "app03-network" = {
    virtual_network_key   = "test"
    destination_vnet_name = "test-network"
  }
  "test-network" = {
    virtual_network_key   = "app03"
    destination_vnet_name = "app03-network"
  }
}
```

### Network Security Group Rules

- **Port 22 (SSH)**: Priority 300
- **Port 80 (HTTP)**: Priority 310

## 🔄 Module Details

### 1. Resource Group Module
- **Path**: `modules/general/resourcegroup`
- **Purpose**: Creates a single resource group container
- **Outputs**: Resource group name and location

### 2. Network Module
- **Path**: `modules/networking/vnet`
- **Purpose**: Creates VNets, subnets, NSGs, public IPs, and NICs
- **Features**:
  - Configurable address spaces
  - Dynamic subnet creation
  - NSG with customizable security rules
  - Public IP allocation
  - Network interface provisioning
- **Outputs**: Subnet IDs, NIC IDs, public IPs, VNet IDs

### 3. VNet Peering Module
- **Path**: `modules/networking/vnetpeering`
- **Purpose**: Establishes bidirectional VNet peering
- **Naming Convention**: `{source}-to-{destination}`
- **Features**:
  - Allows virtual network access
  - Enables cross-VNet communication
  - No gateway transit (configurable)

### 4. Virtual Machines Module
- **Path**: `modules/Compute/VirtualMachines`
- **Purpose**: Provisions Linux VMs with web servers
- **VM Specifications**:
  - **OS**: Ubuntu Server 18.04-LTS
  - **Size**: Standard_B1s
  - **Admin User**: `adminuser`
  - **Password**: `Azure@1234` ⚠️ (Change in production!)
- **Post-Deployment** (copyfiles.tf):
  - Installs nginx via cloud-init
  - Waits 180 seconds for installation completion
  - Uploads custom HTML page via SSH
  - Moves file to nginx web root (`/var/www/html/Default.html`)

## 🔐 Security Considerations

### ⚠️ Production Recommendations

1. **Authentication**:
   - Replace password authentication with **SSH keys**
   - Use **Azure Key Vault** for secrets management
   
2. **Network Security**:
   - Restrict NSG rules to specific IP ranges (not 0.0.0.0/0)
   - Implement **Azure Bastion** for secure VM access
   - Remove public IPs where not needed
   - Use **private endpoints** for internal communication

3. **State Management**:
   - Use **remote backend** (Azure Storage with state locking)
   - Enable encryption for state files
   - Never commit `terraform.tfstate` to source control
   
4. **Access Control**:
   - Implement **Azure RBAC** for resource management
   - Use **managed identities** for service authentication
   - Follow principle of least privilege

## 📊 Resource Dependencies

```
Resource Group
    ↓
Network Module (creates VNets, Subnets, NSGs, IPs, NICs)
    ↓
    ├─> VNet Peering Module (links VNets)
    └─> VM Module (provisions VMs, installs nginx, uploads content)
```

## 🧪 Testing VNet Peering

1. **SSH into VM in app03-network**:
   ```bash
   ssh adminuser@<app03-public-ip>
   ```

2. **Ping the test-network VM** (using private IP):
   ```bash
   ping 10.1.0.4  # Example private IP
   ```

3. **Test HTTP connectivity**:
   ```bash
   curl http://10.1.0.4/Default.html
   ```

4. **Verify peering status**:
   ```powershell
   az network vnet peering list --resource-group app-grp --vnet-name app03-network --output table
   ```

## 📝 Customization

### Add More Environments

Update `terraform.tfvars`:

```hcl
environment = {
  app03 = { ... }
  test = { ... }
  prod = {
    vnet_name           = "prod-network"
    vnet_address_prefix = "10.2.0.0/16"
    vm_count            = 2
    vnet_subnet_count   = 2
    network_interface_count = 2
    public_ip_address_count = 2
  }
}
```

### Modify NSG Rules

```hcl
network_security_group_rules = [
  {
    priority               = 300
    destination_port_range = "22"
  },
  {
    priority               = 310
    destination_port_range = "443"  # HTTPS
  },
  {
    priority               = 320
    destination_port_range = "3389"  # RDP (if Windows VMs)
  }
]
```

### Scale VMs

Change `vm_count` in `terraform.tfvars`:

```hcl
app03 = {
  # ...existing code...
  vm_count                = 3  # Creates 3 VMs
  network_interface_count = 3
  public_ip_address_count = 3
}
```

## 🛠️ Troubleshooting

### Import Existing Resources

If resources already exist in Azure:

```powershell
# Import resource group
terraform import 'module.resourcegroup.azurerm_resource_group.appgrp' /subscriptions/2ab4f266-3113-46c7-9a11-16bcb8ae5659/resourceGroups/app-grp

# Import virtual network
terraform import 'module.network["app03"].azurerm_virtual_network.virtual_network' /subscriptions/2ab4f266-3113-46c7-9a11-16bcb8ae5659/resourceGroups/app-grp/providers/Microsoft.Network/virtualNetworks/app03-network

# Import subnet
terraform import 'module.network["app03"].azurerm_subnet.subnet[0]' /subscriptions/2ab4f266-3113-46c7-9a11-16bcb8ae5659/resourceGroups/app-grp/providers/Microsoft.Network/virtualNetworks/app03-network/subnets/<subnet-name>
```

### Common Issues

| Issue | Solution |
|-------|----------|
| **Invalid VNet Peering Name** | Ensure names use hyphens, not spaces (`app03-network-to-test-network`) |
| **SSH Connection Timeout** | Wait 180 seconds after deployment for nginx installation to complete |
| **State Lock** | Check for running operations or manually unlock: `terraform force-unlock <lock-id>` |
| **429 Rate Limit** | Azure throttling — wait and retry, or increase timeouts in provider config |
| **Public IP not accessible** | Verify NSG rules allow your source IP on port 22/80 |

### Enable Debug Logging

```powershell
$env:TF_LOG = "DEBUG"
terraform apply
```

## 📈 Cost Optimization

- **VM Size**: Standard_B1s is burstable and cost-effective for dev/test
- **Public IPs**: Remove if not needed (use Azure Bastion instead)
- **Deallocate VMs**: When not in use to save compute costs
- **Use Azure Cost Management**: Monitor spending and set budgets

## 🔄 CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Terraform Deploy

on:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        run: terraform init
      - name: Terraform Plan
        run: terraform plan
      - name: Terraform Apply
        run: terraform apply -auto-approve
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
```

## 📚 Additional Resources

- [Azure Virtual Network Peering Documentation](https://learn.microsoft.com/azure/virtual-network/virtual-network-peering-overview)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is provided as-is for educational and demonstration purposes.

---

**⚠️ Important**: This infrastructure is designed for **development/testing**. Follow Azure security best practices and the Well-Architected Framework before deploying to production environments.

**Author**: [Your Name]  
**Last Updated**: November 29, 2025
