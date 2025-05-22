# Module Name

A terraform module for deploying worker and control plane nodes that can be used by Kubernetes. 

## Usage

Below is a basic example of how to use this module. For more detailed examples, please refer to the [examples](./examples) directory.

```terraform
module "example" {
  # Use commit hash to prevent supply chain attacks.
  source = "github.com/vetlekise/terraform-proxmox-k8s_nodes"

  # Module Inputs
  proxmox_target_node = "pve" # Your Proxmox node name
  template_name       = "ubuntu-2204-cloudinit-template" # Your VM template

  # Node Counts
  control_plane_count = 2
  worker_count        = 3

  # Naming and VMIDs
  control_plane_name_prefix = "k8s-cp-"
  worker_name_prefix        = "k8s-worker-"
  node_name_suffix_format   = "%02d" # e.g., k8s-cp-01, k8s-worker-01
  control_plane_base_vmid   = 200    # VMs will be 200, 201
  worker_base_vmid          = 300    # VMs will be 300, 301, 302

  # Pool Names
  control_plane_pool_name = "controlplane-pool"
  worker_pool_name        = "worker-pool"

  # Common VM Settings
  initial_vm_state = "running"
  agent_enabled    = true
  full_clone       = true

  # Default Hardware (used if not overridden by specific type)
  default_vm_memory    = 4096 # 4GB
  default_vm_cores     = 2
  default_vm_sockets   = 1
  default_os_disk_size = "50G"

  # Control Plane Specific Hardware (examples, nulls will use defaults)
  # control_plane_vm_memory = 8192
  # control_plane_vm_cores  = 4

  # Worker Specific Hardware
  worker_vm_memory = 8192
  worker_vm_cores  = 4

  # Disk Configuration
  default_os_disk_storage        = "local-lvm"
  default_cloudinit_disk_storage = "local"

  # Cloud-Init
  ciuser                 = "ubuntu" # Or your template's default cloud-init user
  ssh_public_keys_file   = "path/to/your/ssh_key.pub"
  default_ip_config      = "ip=dhcp" # Fallback IP config

  # Example Static IP configuration (ensure list length matches counts)
  control_plane_ip_configs = [
    "ip=192.168.1.20/24,gw=192.168.1.1",
    "ip=192.168.1.21/24,gw=192.168.1.1",
  ]
  worker_ip_configs = [
    "ip=192.168.1.30/24,gw=192.168.1.1",
    "ip=192.168.1.31/24,gw=192.168.1.1",
    "ip=192.168.1.32/24,gw=192.168.1.1",
  ]

  nameserver   = "8.8.8.8"
  searchdomain = "lab.local"

  # Network
  network_bridge = "vmbr0"
  network_model  = "virtio"
  }
```

> Beginning of generated docs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->

> End of generated docs

## Contributing
Start by reviewing [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for guidelines on how to contribute to this project.
