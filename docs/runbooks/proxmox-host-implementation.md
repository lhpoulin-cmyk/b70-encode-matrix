# Host implementation packet: VM 9310

This is a reviewed packet for an authorized Proxmox administrator. It is not to
be executed from VM 310.

1. Review `proxmox/example-profile.yaml` and render `create-template.sh`.
2. Create VM 9310 with q35/OVMF, 6 vCPU, 12 GiB, 40 GiB managed SCSI disk,
   VirtIO NIC, serial console, and cloud-init; attach no GPU or raw disk.
3. Install/import Ubuntu Server 26.04 and install the exact released repository.
4. Run generic `bootstrap/install.sh --template-mode`; test without expecting a
   GPU. Add `/etc/b70-encode-template-candidate` with release/template identity.
5. Run sanitization inside 9310 after triple-checking hostname and marker. It
   removes evidence, jobs, logs, scratch/results, credentials, Git credentials,
   mount configuration, cloud-init state, machine ID, and SSH host keys.
6. Shut down and do not reboot. On the host run `qm template 9310` only after
   review.
7. Create logical PCI mapping `gpu-encode-b70` under Datacenter resource
   mappings and verify exclusivity; actual PCI evidence remains private.
8. Render and apply `deploy-instance.sh` against a private profile. Clone 9310,
   configure identity/resources/cloud-init, attach mapping and optional scratch,
   then boot.
9. In the clone, install the hardware profile, finalize instance state, and run
   smoke/regression/representative acceptance. Promote only after all required
   gates and manual media/thermal checks pass.
10. Rollback: preserve failure evidence, stop the new clone, detach its logical
    resource assignment if necessary, and remove only the failed clone after
    approval. Never modify or convert VM 310; retain 9310 for repeatable clones.
