# AGENTS.md — Helix-ARPA GPU Encode Appliance

## Identity and mission

This machine is a dedicated GPU media-pipeline appliance. It is not a
general-purpose compute node, desktop, container host, or unrelated application
server. Its mission is reproducible media ingestion, inspection, hardware
encoding, validation, promotion, and pipeline automation.

Priorities are correctness, source preservation, reproducibility, evidence,
operational reliability, then performance. Performance never overrides
correctness or source preservation.

## Active hardware profile

The installed `config/active-hardware-profile.yaml` defines the expected GPU,
kernel driver, userspace media driver, render device, supported hardware APIs,
production encoders, experimental encoders, and required validation tests.
Deployment configuration may override instance-dependent values such as the
render node. Verify the active profile and observed state at the start of every
implementation or diagnostic task. Profile declarations are expectations, not
proof that hardware is working.

## Authority boundary

Guest agents may inspect and modify approved guest packages, configuration,
scripts, tests, documentation, and pipeline services. Host-level GPU, storage,
virtualization, VFIO, IOMMU, PCI passthrough, VM hardware, physical disk,
network infrastructure, other VM, and resource-mapping changes are outside
guest authority. Stop and report host-side requirements; do not cross this
boundary automatically.

## Workspace and storage

The canonical workspace is `/srv/b70-encode`. Supported commands are in `bin/`;
versioned profiles in `config/`; policy and runbooks in `docs/`; raw evidence in
`evidence/`; state transitions in `jobs/`; runtime logs in `logs/`; pipeline
definitions in `pipelines/`; bounded work in `scratch/`; validation in `tests/`;
and disposable task files in `tmp/`.

Reserved external paths are `/mnt/media/source`, `/mnt/media/work`,
`/mnt/media/output`, and `/mnt/media/archive`. Their existence does not prove a
mount exists. Verify the exact mount with `findmnt -M` before access or writes.

Before substantial output verify destination filesystem, available bytes and
inodes, expected output size, scratch use, and mount state. Local workspace
storage must retain whichever reserve leaves more free capacity: 20 percent or
30 GiB. Never redirect a large encode to the root filesystem because an
external mount is absent.

## Source preservation

Original media is immutable. Never encode over, destructively rename, delete,
or needlessly change timestamps on source media. A failed job never removes its
input. Prefer read-only source mounts. Read from source, write to a distinct
work or output path, validate, then promote separately. Deletion and archival
are independent operator decisions.

## Hardware acceleration

Hardware API, encoder, and device must be explicitly selected and verified.
Software fallback is prohibited unless the job explicitly authorizes it. Never
silently substitute another hardware API or encoder. If initialization fails,
fail clearly and preserve complete logs. Encoder enumeration and fast execution
are not proof of hardware acceleration; confirm the intended path from FFmpeg
logs and telemetry where practical.

## Output promotion

Incomplete output uses a temporary suffix such as `.part`. Every promoted
output requires a successful encode, output probe, full decode validation when
required, SHA-256 checksum, provenance, and retained logs. It must also be
nonempty, contain the expected streams and codec, show the intended hardware
path, and satisfy audio, subtitle, chapter, attachment, metadata, HDR, and color
policies. Promotion should be atomic on one filesystem.

## Media policy

Do not make unrequested creative decisions. Unless a job specification says
otherwise, preserve audio, subtitles, chapters, useful metadata, language tags,
HDR signalling, and color metadata. Do not change frame rate, crop,
deinterlace, denoise, resize, normalize audio, burn subtitles, or discard
commentary or alternate-language tracks. Inspect first, encode second, validate
third.

## Evidence and job state

Every production record contains the FFmpeg version, full command, input probe,
selected device/API/encoder, relevant drivers, timestamps, exit status, output
probe, decode result, checksum, and provenance. Jobs move
`queued → running → succeeded` or `queued → running → failed`, have a unique ID,
and retain request, environment, logs, results, status, and failure reason.
FFmpeg exit zero alone is not job success.

Raw evidence belongs under `evidence/<timestamp>-<change-id>/`. Never rewrite
raw evidence; add a correction that references it. Do not commit raw evidence,
logs, runtime job state, media, generated outputs, credentials, or secrets.

## Bounded changes and packages

For nontrivial changes: observe; record original state; state intent; identify
rollback; apply the smallest change; test exact function; regress production;
record evidence; update `CURRENT_STATE.md`; commit sanitized artifacts.

Prefer Ubuntu repository packages. Before package changes record installed and
candidate versions, origins, dependencies, holds, active FFmpeg, proposed
removals, and rollback. Never run a broad unattended distribution upgrade for a
focused repair. Do not add repositories or compile FFmpeg, media runtimes, or
drivers without documented need, rollback, and operator authorization.

## Script standards

Shell scripts use `#!/usr/bin/env bash`, `set -Eeuo pipefail`, quoted variables,
required-argument and command checks, explicit paths, machine-readable data
where available, useful errors, and nonzero failure status. They avoid input
deletion, write temporary output before promotion, expose FFmpeg stderr, retain
failed logs, and are safe to rerun where practical. Overwrite or deletion
requires explicit confirmation and a documented dry-run mode.

## Testing

Smoke tests check workspace, active profile, required commands, media tools,
expected device access, driver, and encoder exposure. Regression tests add a
synthetic production encode, output probe, full decode, checksum, fallback
rejection, MakeMKV policy, free-space guard, and continued production-profile
operation. Acceptance tests add physical identity, representative media, bit
depth, HDR/SDR, audio/subtitle policy, performance, thermal/error observation,
repeated invocation, production command, and rollback.

Experimental encoder failure does not fail appliance acceptance unless the
deployment profile explicitly requires that encoder.

## Documentation and stop conditions

After an approved change update `CURRENT_STATE.md`, relevant runbook/profile,
and `CHANGELOG.md`. “Works” must name command, API, codec, input characteristics,
validated output, and versions.

Stop when the machine or expected hardware is wrong; render device changes
unexpectedly; source immutability is at risk; a required mount is absent; free
space is below reserve; a package action removes the production stack; host
changes, repartitioning, or an unapproved repository are required; production
regression or output validation fails; or software fallback cannot be ruled
out.

## Definition of done

A task is complete only when intended function and output validation succeed,
production remains explicit, no source was modified, no silent fallback
occurred, regression passes, evidence and documentation are current, rollback
is known, and remaining limitations are stated.
