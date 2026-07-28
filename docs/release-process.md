# Release process

Semantic appliance releases use `gpu-encode-vMAJOR.MINOR.PATCH`; the initial
intended release is `gpu-encode-v0.1.0`, with template
`tpl-gpu-encode-ubuntu2604-v0.1.0`.

1. Require a clean Git worktree.
2. Pass regression on VM 310.
3. Verify no secrets, private profiles, evidence, logs, media, or outputs track.
4. Pass generic bootstrap dry-run/static tests.
5. Review template-build and sanitization instructions.
6. Create the signed/annotated release tag.
7. Build and sanitize a template from that release.
8. Clone it with a private deployment profile.
9. Pass fresh-clone acceptance and generate instance state.
10. Promote the release and retain rollback/evidence.

Do not tag `gpu-encode-v0.1.0` until restructuring and regressions are complete.
Every instance records release, commit, template, hardware profile, deployment
profile identifier, identity, and creation date.
