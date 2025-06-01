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
  cluster_name              = "cluster"
  control_plane_name_prefix = "control-plane-"
  worker_name_prefix        = "worker-"
  node_name_suffix_format   = "%02d" # e.g., k8s-cp-01, k8s-worker-01
  control_plane_base_vmid   = 200    # VMs will be 200, 201
  worker_base_vmid          = 300    # VMs will be 300, 301, 302
  common_tags               = ["cluster"]
  control_plane_tags        = ["control_planes"]
  worker_tags               = ["workers"]

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
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.1-rc8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 3.0.1-rc8 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_pool.cluster_pool](https://registry.terraform.io/providers/telmate/proxmox/3.0.1-rc8/docs/resources/pool) | resource |
| [proxmox_vm_qemu.control_plane_node](https://registry.terraform.io/providers/telmate/proxmox/3.0.1-rc8/docs/resources/vm_qemu) | resource |
| [proxmox_vm_qemu.worker_node](https://registry.terraform.io/providers/telmate/proxmox/3.0.1-rc8/docs/resources/vm_qemu) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_enabled"></a> [agent\_enabled](#input\_agent\_enabled) | Enable the QEMU Guest Agent (requires agent installed in the template). | `bool` | `true` | no |
| <a name="input_cdrom_ide_slot"></a> [cdrom\_ide\_slot](#input\_cdrom\_ide\_slot) | IDE slot for the CD-ROM drive (e.g., 'ide2'). Ensure this doesn't conflict with cloudinit\_ide\_slot. | `string` | `"ide2"` | no |
| <a name="input_cipassword"></a> [cipassword](#input\_cipassword) | Cloud-Init user password. Sensitive. Recommended to use null and rely on SSH keys. | `string` | `null` | no |
| <a name="input_ciuser"></a> [ciuser](#input\_ciuser) | Cloud-Init username to configure. | `string` | `"adminuser"` | no |
| <a name="input_cloudinit_ide_slot"></a> [cloudinit\_ide\_slot](#input\_cloudinit\_ide\_slot) | IDE slot for the Cloud-Init drive (e.g., 'ide0'). Ensure this doesn't conflict with cdrom\_ide\_slot. | `string` | `"ide0"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name for the Proxmox resource pool that will contain all cluster nodes, and will also be used as a common tag for all nodes. | `string` | `"cluster"` | no |
| <a name="input_control_plane_base_vmid"></a> [control\_plane\_base\_vmid](#input\_control\_plane\_base\_vmid) | Starting VMID for control plane nodes. If set to 0, Proxmox will assign the next available ID for each. If > 0, subsequent VMs get base\_vmid + index. | `number` | `0` | no |
| <a name="input_control_plane_cloudinit_disk_storage"></a> [control\_plane\_cloudinit\_disk\_storage](#input\_control\_plane\_cloudinit\_disk\_storage) | Storage for control plane Cloud-Init drives. Overrides default\_cloudinit\_disk\_storage. | `string` | `null` | no |
| <a name="input_control_plane_count"></a> [control\_plane\_count](#input\_control\_plane\_count) | Number of control plane nodes to create. | `number` | `0` | no |
| <a name="input_control_plane_ip_configs"></a> [control\_plane\_ip\_configs](#input\_control\_plane\_ip\_configs) | List of IP configurations for control plane nodes (e.g., ['ip=10.0.1.10/24,gw=10.0.1.1', 'ip=10.0.1.11/24,gw=10.0.1.1']). Length should match control\_plane\_count. Empty/null entries use default\_ip\_config. | `list(string)` | `[]` | no |
| <a name="input_control_plane_name_prefix"></a> [control\_plane\_name\_prefix](#input\_control\_plane\_name\_prefix) | Prefix for control plane VM names. Full name will be prefix + suffix\_format (e.g., 'controlplane-'). | `string` | `"control-plane-"` | no |
| <a name="input_control_plane_os_disk_size"></a> [control\_plane\_os\_disk\_size](#input\_control\_plane\_os\_disk\_size) | OS disk size for control plane VMs (e.g., '50G'). Overrides default\_os\_disk\_size. | `string` | `null` | no |
| <a name="input_control_plane_os_disk_storage"></a> [control\_plane\_os\_disk\_storage](#input\_control\_plane\_os\_disk\_storage) | Storage pool for control plane OS disks. Overrides default\_os\_disk\_storage. | `string` | `null` | no |
| <a name="input_control_plane_tags"></a> [control\_plane\_tags](#input\_control\_plane\_tags) | Tags of the VM. Comma-separated values (e.g. tag1,tag2,tag3). Tag may not start with - and may only include the following characters: [a-z], [0-9], \_ and -. This is only meta information | `string` | `"control_planes"` | no |
| <a name="input_control_plane_vm_cores"></a> [control\_plane\_vm\_cores](#input\_control\_plane\_vm\_cores) | Number of CPU cores for control plane VMs. Overrides default\_vm\_cores. | `number` | `null` | no |
| <a name="input_control_plane_vm_memory"></a> [control\_plane\_vm\_memory](#input\_control\_plane\_vm\_memory) | Memory (in MiB) for control plane VMs. Overrides default\_vm\_memory. | `number` | `null` | no |
| <a name="input_control_plane_vm_sockets"></a> [control\_plane\_vm\_sockets](#input\_control\_plane\_vm\_sockets) | Number of CPU sockets for control plane VMs. Overrides default\_vm\_sockets. | `number` | `null` | no |
| <a name="input_default_cloudinit_disk_storage"></a> [default\_cloudinit\_disk\_storage](#input\_default\_cloudinit\_disk\_storage) | Default storage pool for the Cloud-Init drive (must support snippets/ISO images, e.g., 'local'). | `string` | n/a | yes |
| <a name="input_default_ip_config"></a> [default\_ip\_config](#input\_default\_ip\_config) | Default IP configuration for network interfaces if specific list is not provided or an entry is empty (e.g., 'ip=dhcp'). | `string` | `"ip=dhcp"` | no |
| <a name="input_default_os_disk_size"></a> [default\_os\_disk\_size](#input\_default\_os\_disk\_size) | Default target size of the primary OS disk (e.g., '30G'). Must be provided even when cloning if resizing. | `string` | `"32G"` | no |
| <a name="input_default_os_disk_storage"></a> [default\_os\_disk\_storage](#input\_default\_os\_disk\_storage) | Default storage pool for the VMs' primary OS disk (e.g., 'local-lvm'). | `string` | n/a | yes |
| <a name="input_default_vm_cores"></a> [default\_vm\_cores](#input\_default\_vm\_cores) | Default number of CPU cores per socket for VMs. | `number` | `2` | no |
| <a name="input_default_vm_memory"></a> [default\_vm\_memory](#input\_default\_vm\_memory) | Default memory (in MiB) for VMs. | `number` | `2048` | no |
| <a name="input_default_vm_sockets"></a> [default\_vm\_sockets](#input\_default\_vm\_sockets) | Default number of CPU sockets for VMs. | `number` | `1` | no |
| <a name="input_full_clone"></a> [full\_clone](#input\_full\_clone) | Set to true for a full clone, false for a linked clone. | `bool` | `true` | no |
| <a name="input_initial_vm_state"></a> [initial\_vm\_state](#input\_initial\_vm\_state) | Desired state for VMs after creation - 'running' or 'stopped'. | `string` | `"stopped"` | no |
| <a name="input_nameserver"></a> [nameserver](#input\_nameserver) | DNS server for the VMs (applied via Cloud-Init). | `string` | `null` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge for the VMs' primary network interface (e.g., 'vmbr0'). | `string` | n/a | yes |
| <a name="input_network_firewall"></a> [network\_firewall](#input\_network\_firewall) | Enable/disable Proxmox firewall on the network interface. | `bool` | `false` | no |
| <a name="input_network_model"></a> [network\_model](#input\_network\_model) | Network card model (e.g., 'virtio', 'e1000'). | `string` | `"virtio"` | no |
| <a name="input_node_name_suffix_format"></a> [node\_name\_suffix\_format](#input\_node\_name\_suffix\_format) | Format for the numeric suffix of node names (e.g., '%d', '%02d'). Applied to count.index + 1. | `string` | `"%d"` | no |
| <a name="input_os_disk_discard"></a> [os\_disk\_discard](#input\_os\_disk\_discard) | Enable/disable discard (TRIM) for the OS disk. | `bool` | `true` | no |
| <a name="input_os_disk_iothread"></a> [os\_disk\_iothread](#input\_os\_disk\_iothread) | Enable/disable iothread for the OS disk. | `bool` | `true` | no |
| <a name="input_os_disk_slot"></a> [os\_disk\_slot](#input\_os\_disk\_slot) | The slot for the primary OS disk (e.g., 'scsi0', 'virtio0'). This must match the controller type in the 'disks' block. | `string` | `"scsi0"` | no |
| <a name="input_os_disk_ssd"></a> [os\_disk\_ssd](#input\_os\_disk\_ssd) | Emulate SSD for the OS disk (ssd=1). | `bool` | `true` | no |
| <a name="input_protection"></a> [protection](#input\_protection) | If true, enable the protection flag on the VMs in Proxmox. | `bool` | `false` | no |
| <a name="input_proxmox_target_node"></a> [proxmox\_target\_node](#input\_proxmox\_target\_node) | Proxmox node where the VMs will be created. | `string` | n/a | yes |
| <a name="input_qemu_os"></a> [qemu\_os](#input\_qemu\_os) | Guest OS type for Proxmox optimizations (e.g., 'l26' for Linux, 'windows' for Windows type). | `string` | `"l26"` | no |
| <a name="input_scsihw"></a> [scsihw](#input\_scsihw) | SCSI hardware controller type (e.g., 'virtio-scsi-pci', 'lsi'). Should match template capabilities. | `string` | `"virtio-scsi-single"` | no |
| <a name="input_searchdomain"></a> [searchdomain](#input\_searchdomain) | DNS search domain for the VMs (applied via Cloud-Init). | `string` | `null` | no |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | String containing newline-separated public SSH keys. Mutually exclusive with ssh\_public\_keys\_file. | `string` | `null` | no |
| <a name="input_ssh_public_keys_file"></a> [ssh\_public\_keys\_file](#input\_ssh\_public\_keys\_file) | Path to a file containing SSH public keys (one per line). Mutually exclusive with ssh\_public\_keys. | `string` | `null` | no |
| <a name="input_template_name"></a> [template\_name](#input\_template\_name) | Name of the EXISTING Proxmox template to clone from. | `string` | n/a | yes |
| <a name="input_vga_type"></a> [vga\_type](#input\_vga\_type) | Display type (e.g., 'serial0', 'std', 'qxl'). 'serial0' is good for headless servers. | `string` | `"std"` | no |
| <a name="input_worker_base_vmid"></a> [worker\_base\_vmid](#input\_worker\_base\_vmid) | Starting VMID for worker nodes. If set to 0, Proxmox will assign the next available ID for each. If > 0, subsequent VMs get base\_vmid + index. | `number` | `0` | no |
| <a name="input_worker_cloudinit_disk_storage"></a> [worker\_cloudinit\_disk\_storage](#input\_worker\_cloudinit\_disk\_storage) | Storage for worker Cloud-Init drives. Overrides default\_cloudinit\_disk\_storage. | `string` | `null` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Number of worker nodes to create. | `number` | `0` | no |
| <a name="input_worker_ip_configs"></a> [worker\_ip\_configs](#input\_worker\_ip\_configs) | List of IP configurations for worker nodes. Length should match worker\_count. Empty/null entries use default\_ip\_config. | `list(string)` | `[]` | no |
| <a name="input_worker_name_prefix"></a> [worker\_name\_prefix](#input\_worker\_name\_prefix) | Prefix for worker VM names. Full name will be prefix + suffix\_format (e.g., 'worker-'). | `string` | `"worker-"` | no |
| <a name="input_worker_os_disk_size"></a> [worker\_os\_disk\_size](#input\_worker\_os\_disk\_size) | OS disk size for worker VMs (e.g., '100G'). Overrides default\_os\_disk\_size. | `string` | `null` | no |
| <a name="input_worker_os_disk_storage"></a> [worker\_os\_disk\_storage](#input\_worker\_os\_disk\_storage) | Storage pool for worker OS disks. Overrides default\_os\_disk\_storage. | `string` | `null` | no |
| <a name="input_worker_tags"></a> [worker\_tags](#input\_worker\_tags) | Tags of the VM. Comma-separated values (e.g. tag1,tag2,tag3). Tag may not start with - and may only include the following characters: [a-z], [0-9], \_ and -. This is only meta information | `string` | `"workers"` | no |
| <a name="input_worker_vm_cores"></a> [worker\_vm\_cores](#input\_worker\_vm\_cores) | Number of CPU cores for worker VMs. Overrides default\_vm\_cores. | `number` | `null` | no |
| <a name="input_worker_vm_memory"></a> [worker\_vm\_memory](#input\_worker\_vm\_memory) | Memory (in MiB) for worker VMs. Overrides default\_vm\_memory. | `number` | `null` | no |
| <a name="input_worker_vm_sockets"></a> [worker\_vm\_sockets](#input\_worker\_vm\_sockets) | Number of CPU sockets for worker VMs. Overrides default\_vm\_sockets. | `number` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

> End of generated docs

## Contributing
Start by reviewing [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for guidelines on how to contribute to this project.
