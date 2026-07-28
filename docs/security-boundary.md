# Security boundary

The repository contains no credentials, private deployment profiles, SSH keys,
tokens, media, raw evidence, logs, generated outputs, machine identity, or host
PCI/disk assignments. Cloud-init examples use visible placeholders. Real
deployment facts belong in a separately access-controlled infrastructure
repository.

Guest authority ends at the virtual hardware boundary. Host administrators
create templates, resource mappings, passthrough, storage, and clones. Guest
bootstrap installs only approved Ubuntu packages and appliance configuration.
Sanitization is destructive only on a marked template candidate and refuses
the reference identity.
