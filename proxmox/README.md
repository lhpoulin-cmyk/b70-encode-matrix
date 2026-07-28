# Proxmox tooling

These scripts are reviewed host-side tooling. Run them only on an authorized
Proxmox host after `--dry-run` review. They never use VM 310 as a clone source,
never embed a physical PCI address, and refer to GPUs through logical Proxmox
resource mappings. `sanitize-template.sh` is the sole guest-side exception and
is guarded for template VM 9310 candidates only.

Typical flow: render/create candidate, install appliance in template mode,
sanitize and shut down, manually review `qm template 9310`, create/verify the
logical PCI mapping, deploy clone from the template, then finalize and accept in
the clone.
