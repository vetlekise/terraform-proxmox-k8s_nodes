# General Proxmox Settings
variable "proxmox_target_node" {
  description = "Proxmox node where the VMs will be created."
  type        = string
}

variable "template_name" {
  description = "Name of the EXISTING Proxmox template to clone from."
  type        = string
}

# Node Counts
variable "control_plane_count" {
  description = "Number of control plane nodes to create."
  type        = number
  default     = 0
}

variable "worker_count" {
  description = "Number of worker nodes to create."
  type        = number
  default     = 0
}

variable "cluster_name" {
  description = "The name for the Proxmox resource pool that will contain all cluster nodes."
  type        = string
  default     = "k8s-cluster"
}

# Naming and VMID
variable "control_plane_name_prefix" {
  description = "Prefix for control plane VM names. Full name will be prefix + suffix_format (e.g., 'controlplane-')."
  type        = string
  default     = "control-plane-"
}

variable "worker_name_prefix" {
  description = "Prefix for worker VM names. Full name will be prefix + suffix_format (e.g., 'worker-')."
  type        = string
  default     = "worker-"
}

variable "node_name_suffix_format" {
  description = "Format for the numeric suffix of node names (e.g., '%d', '%02d'). Applied to count.index + 1."
  type        = string
  default     = "%d" # Results in names like cp-1, worker-1
}

variable "control_plane_base_vmid" {
  description = "Starting VMID for control plane nodes. If set to 0, Proxmox will assign the next available ID for each. If > 0, subsequent VMs get base_vmid + index."
  type        = number
  default     = 0
}

variable "worker_base_vmid" {
  description = "Starting VMID for worker nodes. If set to 0, Proxmox will assign the next available ID for each. If > 0, subsequent VMs get base_vmid + index."
  type        = number
  default     = 0
}

# Common VM Settings
variable "initial_vm_state" {
  description = "Desired state for VMs after creation - 'running' or 'stopped'."
  type        = string
  default     = "stopped"
  validation {
    condition     = contains(["running", "stopped"], var.initial_vm_state)
    error_message = "Allowed values for initial_vm_state are 'running' or 'stopped'."
  }
}

variable "protection" {
  description = "If true, enable the protection flag on the VMs in Proxmox."
  type        = bool
  default     = false
}

variable "qemu_os" {
  description = "Guest OS type for Proxmox optimizations (e.g., 'l26' for Linux, 'windows' for Windows type)."
  type        = string
  default     = "l26" # Linux 2.6 / 3.x / 4.x Kernel
}

variable "agent_enabled" {
  description = "Enable the QEMU Guest Agent (requires agent installed in the template)."
  type        = bool
  default     = true
}

variable "full_clone" {
  description = "Set to true for a full clone, false for a linked clone."
  type        = bool
  default     = true
}

variable "vga_type" {
  description = "Display type (e.g., 'serial0', 'std', 'qxl'). 'serial0' is good for headless servers."
  type        = string
  default     = "std"
}

variable "scsihw" {
  description = "SCSI hardware controller type (e.g., 'virtio-scsi-pci', 'lsi'). Should match template capabilities."
  type        = string
  default     = "virtio-scsi-single" # Good default for performance with VirtIO drivers
}

# Default Hardware Specifications
variable "default_vm_memory" {
  description = "Default memory (in MiB) for VMs."
  type        = number
  default     = 2048
}

variable "default_vm_cores" {
  description = "Default number of CPU cores per socket for VMs."
  type        = number
  default     = 2
}

variable "default_vm_sockets" {
  description = "Default number of CPU sockets for VMs."
  type        = number
  default     = 1
}

variable "default_os_disk_size" {
  description = "Default target size of the primary OS disk (e.g., '30G'). Must be provided even when cloning if resizing."
  type        = string
  default     = "32G"
}

# Control Plane Specific Hardware
variable "control_plane_vm_memory" {
  description = "Memory (in MiB) for control plane VMs. Overrides default_vm_memory."
  type        = number
  default     = null # Uses default_vm_memory if null
}

variable "control_plane_vm_cores" {
  description = "Number of CPU cores for control plane VMs. Overrides default_vm_cores."
  type        = number
  default     = null # Uses default_vm_cores if null
}

variable "control_plane_vm_sockets" {
  description = "Number of CPU sockets for control plane VMs. Overrides default_vm_sockets."
  type        = number
  default     = null # Uses default_vm_sockets if null
}

variable "control_plane_os_disk_size" {
  description = "OS disk size for control plane VMs (e.g., '50G'). Overrides default_os_disk_size."
  type        = string
  default     = null # Uses default_os_disk_size if null
}

# Worker Specific Hardware
variable "worker_vm_memory" {
  description = "Memory (in MiB) for worker VMs. Overrides default_vm_memory."
  type        = number
  default     = null
}

variable "worker_vm_cores" {
  description = "Number of CPU cores for worker VMs. Overrides default_vm_cores."
  type        = number
  default     = null
}

variable "worker_vm_sockets" {
  description = "Number of CPU sockets for worker VMs. Overrides default_vm_sockets."
  type        = number
  default     = null
}

variable "worker_os_disk_size" {
  description = "OS disk size for worker VMs (e.g., '100G'). Overrides default_os_disk_size."
  type        = string
  default     = null
}

# Disk Configuration
variable "os_disk_slot" {
  description = "The slot for the primary OS disk (e.g., 'scsi0', 'virtio0'). This must match the controller type in the 'disks' block."
  type        = string
  default     = "scsi0"
}

variable "default_os_disk_storage" {
  description = "Default storage pool for the VMs' primary OS disk (e.g., 'local-lvm')."
  type        = string
}

variable "control_plane_os_disk_storage" {
  description = "Storage pool for control plane OS disks. Overrides default_os_disk_storage."
  type        = string
  default     = null
}

variable "worker_os_disk_storage" {
  description = "Storage pool for worker OS disks. Overrides default_os_disk_storage."
  type        = string
  default     = null
}

variable "os_disk_discard" {
  description = "Enable/disable discard (TRIM) for the OS disk."
  type        = bool
  default     = true
}

variable "os_disk_iothread" {
  description = "Enable/disable iothread for the OS disk."
  type        = bool
  default     = true # Requires scsihw supporting iothread like 'virtio-scsi-single' or 'virtio-scsi-pci'
}

variable "os_disk_ssd" {
  description = "Emulate SSD for the OS disk (ssd=1)."
  type        = bool
  default     = true
}

# Cloud-Init Disk Configuration
variable "cloudinit_ide_slot" {
  description = "IDE slot for the Cloud-Init drive (e.g., 'ide0'). Ensure this doesn't conflict with cdrom_ide_slot."
  type        = string
  default     = "ide0"
}

variable "cdrom_ide_slot" {
  description = "IDE slot for the CD-ROM drive (e.g., 'ide2'). Ensure this doesn't conflict with cloudinit_ide_slot."
  type        = string
  default     = "ide2"
}

variable "default_cloudinit_disk_storage" {
  description = "Default storage pool for the Cloud-Init drive (must support snippets/ISO images, e.g., 'local')."
  type        = string
}

variable "control_plane_cloudinit_disk_storage" {
  description = "Storage for control plane Cloud-Init drives. Overrides default_cloudinit_disk_storage."
  type        = string
  default     = null
}

variable "worker_cloudinit_disk_storage" {
  description = "Storage for worker Cloud-Init drives. Overrides default_cloudinit_disk_storage."
  type        = string
  default     = null
}

# Cloud-Init User and Network Configuration
variable "ciuser" {
  description = "Cloud-Init username to configure."
  type        = string
  default     = "adminuser"
}

variable "cipassword" {
  description = "Cloud-Init user password. Sensitive. Recommended to use null and rely on SSH keys."
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "String containing newline-separated public SSH keys. Mutually exclusive with ssh_public_keys_file."
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_public_keys_file" {
  description = "Path to a file containing SSH public keys (one per line). Mutually exclusive with ssh_public_keys."
  type        = string
  default     = null # Example: "keys/id_rsa.pub"
  validation {
    condition     = var.ssh_public_keys_file == null || fileexists(var.ssh_public_keys_file)
    error_message = "If 'ssh_public_keys_file' is specified, the file must exist."
  }
  validation {
    condition     = var.ssh_public_keys == null || var.ssh_public_keys_file == null
    error_message = "Cannot specify both 'ssh_public_keys' and 'ssh_public_keys_file'."
  }
}

variable "default_ip_config" {
  description = "Default IP configuration for network interfaces if specific list is not provided or an entry is empty (e.g., 'ip=dhcp')."
  type        = string
  default     = "ip=dhcp"
}

variable "control_plane_ip_configs" {
  description = "List of IP configurations for control plane nodes (e.g., ['ip=10.0.1.10/24,gw=10.0.1.1', 'ip=10.0.1.11/24,gw=10.0.1.1']). Length should match control_plane_count. Empty/null entries use default_ip_config."
  type        = list(string)
  default     = []
}

variable "worker_ip_configs" {
  description = "List of IP configurations for worker nodes. Length should match worker_count. Empty/null entries use default_ip_config."
  type        = list(string)
  default     = []
}

variable "nameserver" {
  description = "DNS server for the VMs (applied via Cloud-Init)."
  type        = string
  default     = null
}

variable "searchdomain" {
  description = "DNS search domain for the VMs (applied via Cloud-Init)."
  type        = string
  default     = null
}

# Network Interface Configuration
variable "network_bridge" {
  description = "Network bridge for the VMs' primary network interface (e.g., 'vmbr0')."
  type        = string
}

variable "network_model" {
  description = "Network card model (e.g., 'virtio', 'e1000')."
  type        = string
  default     = "virtio"
}

variable "network_firewall" {
  description = "Enable/disable Proxmox firewall on the network interface."
  type        = bool
  default     = false
}

/*
# Optional: If you need static MAC addresses per node
variable "control_plane_mac_addresses" {
  description = "List of MAC addresses for control plane nodes. Length must match control_plane_count."
  type        = list(string)
  default     = []
}

variable "worker_mac_addresses" {
  description = "List of MAC addresses for worker nodes. Length must match worker_count."
  type        = list(string)
  default     = []
}
*/
