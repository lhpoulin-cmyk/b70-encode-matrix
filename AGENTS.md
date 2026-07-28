# AGENTS.md — b70-encode

## Identity and mission

This machine is `b70-encode`, a dedicated media-ingestion, inspection, encoding,
validation, and pipeline-automation appliance. It is not a general-purpose
compute node, desktop, or unrelated application host. Its Intel Arc Pro B70
serves bounded media workloads.

Produce reproducible, inspectable, hardware-accelerated media outputs while
preserving originals, recording provenance, and maintaining a known-good
rollback path. Priorities are correctness, source preservation,
reproducibility, evidence, operational reliability, then performance.

## Hardware baseline

- GPU: Intel Arc Pro B70 (`8086:e223`)
- Kernel driver: `xe`
- Render node: `/dev/dri/renderD128`
- Validated userspace driver: Intel `iHD`
- Production encoder: FFmpeg `av1_vaapi`
- Experimental encoder: FFmpeg `av1_qsv`
- Known QSV condition: oneVPL initialization has failed with `MFX error -9`
- MakeMKV and `makemkvcon`: installed

Verify this baseline at the start of every task.

## Authority boundary

Agents may inspect and modify guest-side packages, configuration, scripts,
tests, documentation, and approved pipeline services. They may not modify the
Proxmox host, VFIO, IOMMU, PCI passthrough, VM hardware, disk partitioning, the
host RTX A400, other VMs, network infrastructure, or external storage layout.
Stop and report evidence of a host-side fault.

## Workspace and storage

The canonical workspace is `/srv/b70-encode`: `bin/` has supported commands;
`config/` versioned profiles; `docs/` policies and runbooks; `evidence/` raw
task evidence; `jobs/` state; `logs/` logs; `pipelines/` definitions;
`scratch/` bounded work; `tests/` validation; and `tmp/` disposable files.

External media paths, only when explicitly mounted, are `/mnt/media/source`,
`/mnt/media/work`, `/mnt/media/output`, and `/mnt/media/archive`. Never infer a
mount from a directory; verify with `findmnt`.

Before substantial output, verify filesystem, bytes, inodes, expected size,
scratch use, and mount state. On local workspace storage retain whichever is
greater: 20 percent free or 30 GiB. Do not start a large root-filesystem encode
because an external mount is absent.

## Production and QSV policy

The production path is `xe → iHD → VA-API → av1_vaapi`, explicitly using
`/dev/dri/renderD128`. Do not silently substitute QSV or software. If hardware
initialization fails, fail clearly and preserve logs.

QSV remains additive and experimental until oneVPL detects hardware;
`av1_qsv` initializes against the B70; a bounded encode, probe, full decode,
and checksum succeed; VA-API passes afterward; and the command is documented.
Encoder enumeration alone is not proof.

## Source preservation and promotion

Original media is immutable. Never encode over, destructively rename, delete,
or needlessly alter timestamps of source media. A failed job never removes its
input. Prefer read-only source mounts. Read source, write a distinct `.part`
file, validate, atomically promote on the same filesystem, and treat deletion
or archival as separate operator decisions.

Promote only after FFmpeg succeeds; FFprobe sees expected streams; required
full decode succeeds; the output is nonempty; expected codec and hardware path
are confirmed; checksum is recorded; and audio, subtitle, chapter, attachment,
and metadata policy is satisfied.

## Media policy

Do not make unrequested creative decisions. Unless specified, preserve audio,
subtitles, chapters, useful metadata, language tags, HDR signalling, and color
metadata. Do not change frame rate, crop, deinterlace, denoise, resize,
normalize audio, burn subtitles, or discard alternate/commentary tracks.
Inspect first, encode second, validate third.

## Evidence and jobs

Every production record contains FFmpeg version, full command, input probe,
render node, API, encoder, drivers, timestamps, exit status, output probe,
decode result, and checksum. Confirm hardware from logs and telemetry where
practical.

Jobs move `queued → running → succeeded` or `queued → running → failed`, have a
unique ID, and contain request, probes, command, environment, log, validation,
checksums, final status, and failure reason. FFmpeg exit zero alone is not job
success.

Raw evidence belongs under `evidence/<timestamp>-<change-id>/` and includes
transcripts, packages, drivers, devices, logs, probes, checksums, tests,
configuration, and report. Never rewrite raw evidence; add a correction file.
Do not commit bulky evidence.

## Bounded change workflow and packages

For every nontrivial change: observe; record original state; state intent;
identify rollback; apply the smallest change; test it; regress production;
record evidence; update `CURRENT_STATE.md`; commit sanitized artifacts.

Prefer Ubuntu packages. Before package changes record installed/candidate
versions, origin, dependencies, holds, active FFmpeg, proposed removals, and
rollback. Do not add repositories without documented need and authorization.
Do not compile FFmpeg, oneVPL, media runtime, or drivers first. Do not perform a
broad unattended upgrade during focused repair.

## Script and test standards

Shell uses `#!/usr/bin/env bash`, `set -Eeuo pipefail`, quoted expansions,
required-argument and command checks, explicit paths, machine-readable output,
nonzero failures, safe reruns, temporary output before promotion, and useful
errors. Never delete input or hide FFmpeg stderr. Destructive/overwrite actions
require explicit confirmation and documented dry-run.

Smoke checks render access, iHD, `av1_vaapi`, and a synthetic encode. Regression
adds probe, full decode, checksum, QSV where relevant, MakeMKV, free-space guard,
and no software fallback. Acceptance adds representative media, bit depth,
HDR/SDR, stream preservation, performance/thermal observation, repetition,
production command, and rollback.

## Documentation and stop conditions

After changes update `CURRENT_STATE.md`, relevant runbook/profile, and
`CHANGELOG.md`. “Works” must name command, API, codec, tested input, validated
output, and versions.

Stop if the machine is unexpected; B70 is missing or not on `xe`; render node
changes; source immutability is at risk; a required mount is absent; root space
is below reserve; package action removes VA-API; host changes/repartitioning or
an unapproved repository is required; VA-API regression or output validation
fails; or software fallback cannot be ruled out.

A task is done only when function and validation succeed, production is
explicit, sources are untouched, fallback did not occur, regression passes,
evidence and docs are complete, rollback is known, and limitations are stated.

