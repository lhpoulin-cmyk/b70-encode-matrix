# Hardware profiles

Profiles in `config/profiles/*/profile.yaml` declare expected vendor, driver,
device semantics, userspace runtime, APIs, production/experimental encoders,
status, and tests. They do not assign a physical PCI function.

`intel-battlemage` is operational: `xe`, iHD, VA-API `av1_vaapi` production,
and QSV `av1_qsv` experimental. `intel-alchemist`, `amd-vaapi`, and
`nvidia-nvenc` are explicit not-yet-validated placeholders and installation is
refused. `generic` is template-only and assumes no GPU during image build.

Deployment may override a render node because enumeration can vary. The active
installed copy is `config/active-hardware-profile.yaml`; it is generated and
Git-ignored. Validation always observes the resolved device rather than
assuming `/dev/dri/renderD128` universally.

Encoder tuning is intentionally separate under `config/encoder-profiles/` so a
hardware contract is not confused with a job's codec/rate-control settings.
