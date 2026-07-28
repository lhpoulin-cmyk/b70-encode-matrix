# Generic template build

The proposed release image is VMID 9310,
`tpl-gpu-encode-ubuntu2604-v0.1.0`: Ubuntu Server 26.04, q35, OVMF/UEFI, 6
vCPU, 12 GiB RAM, 32–40 GiB Proxmox-managed VirtIO-SCSI OS disk, VirtIO
network, serial console, and cloud-init. It has no GPU, raw physical disk,
media mounts, credentials, or instance identity.

Upload and verify the official Ubuntu Server 26.04 ISO on approved Proxmox
storage. On an authorized Proxmox host, review `proxmox/example-profile.yaml`, then run
`proxmox/create-template.sh --dry-run --profile FILE`. The script renders host
commands; it refuses execution inside a guest. Install/import Ubuntu, copy the
released appliance source, run generic template-mode bootstrap, add cloud-init,
then mark the candidate with `/etc/b70-encode-template-candidate`.

After Ubuntu installation, remove the installer ISO and restore boot from
`scsi0`. Inside VM 9310 only, review and execute `proxmox/sanitize-template.sh
--expected-hostname tpl-gpu-encode-ubuntu2604-v0.1.0 --apply`. Shut down and do
not boot again. On the host, convert with `qm template 9310`. Neither script
ever converts VM 310.

The template includes the base OS, generic media tools, workspace, generic
doctrine, bootstrap, hardware profiles, tests, and cloud-init support. It must
exclude reference identity, host keys, machine ID, logs, evidence, job history,
media, external mounts, GPU/raw disk assignment, and credentials.
