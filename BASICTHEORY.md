# Basic Theory — Local Encode Command Plane

## Purpose

`b70-encode` is the durable local command plane for turning operator-supplied
media into a validated, immutable, ready-to-promote package.

Its normal workflow is:

```text
disc or operator-supplied input
→ appliance-owned local intake
→ inspect
→ explicit job manifest
→ hardware encode
→ output probe
→ full decode validation
→ stream-policy validation
→ SHA-256 and provenance
→ immutable ready-to-promote package
```

The appliance does not need an external media mount for intake, inspection,
encoding, validation, or packaging. Those stages use appliance-owned local
storage.

## Storage boundary

External media storage is introduced only when an operator explicitly starts a
promotion operation. Missing external mounts must not block or alter the local
pipeline.

Reserved paths such as `/mnt/media/output` and `/mnt/media/archive` are mount
points, not ordinary output directories. Their existence is not evidence that
storage is mounted. Any promotion-side command must verify the exact mount with
`findmnt` before reading or writing it, and must fail closed when the expected
mount is absent.

The pipeline must never create an ordinary directory at an expected mount path
and mistake root-filesystem storage for the external destination.

## Source ownership and deletion

External or operator-owned source media remains immutable while it is outside
the appliance's managed intake boundary.

Media deliberately brought into appliance-owned local intake becomes a managed
working copy. The appliance may delete that managed copy under a documented
retention policy. Deletion is permitted only for paths confined to declared
appliance-owned roots; it must never target the original disc, an external
source, an external mount, or an arbitrary manifest-supplied path.

Deletion eligibility requires a complete ready-to-promote package containing a
successful encode result, input and output probes, required full-decode result,
stream-policy result, output checksum, hardware-path provenance, complete logs,
and final status. The deletion record must identify the deleted path and
checksum, timestamp, actor, reason, and governing policy.

A failed or incomplete job never removes its input.

## Ready-to-promote contract

A ready-to-promote package is title-scoped and immutable. It contains at least:

- The validated media output.
- Source identity and probe.
- Output identity and probe.
- Encoder profile, complete FFmpeg command, versions, hardware API, and device.
- Evidence that the intended hardware path ran without software fallback.
- Full-decode and stream-policy validation results.
- SHA-256 checksums.
- Retained encode and validation logs.
- Intended destination metadata.
- Final local pipeline status.

The package expresses readiness, not authorization to promote.

## Downstream boundary

The encode pipeline ends at a ready-to-promote package. Promotion and Jellyfin
library management are downstream operations, but the appliance needs a
defined communication boundary with them.

That boundary is a Fastmail bridge between Jellyfin and the pipeline. It uses
the same adapter pattern proven by `agentctl` and related control methods:
discover the available tool interface, validate a structured request, assign a
correlation and idempotency key, dispatch only an authorized operation, and
return a durable structured result. Mail is a transport, not authority. A
message cannot by itself bypass promotion approval, package validation, source
immutability, mount checks, or Jellyfin playback guards.

The bridge must solve and make observable:

- Authentication of the sender and authorization of the requested action.
- Replay and duplicate-delivery resistance.
- Correlation of a Jellyfin title, local job, ready package, promotion attempt,
  and reply.
- Explicit request, accepted, running, succeeded, failed, and retryable states.
- Safe handling of delayed, reordered, malformed, or partial messages.
- Redaction of credentials and tokens while retaining commands, decisions,
  timestamps, and failure evidence.
- Reconciliation after either side or the mail transport is unavailable.

The bridge may request inspection, submit or query a local job, report package
readiness, request an explicitly authorized promotion, trigger a Jellyfin scan,
and report downstream visibility. It does not copy media merely because
Jellyfin or Fastmail is reachable. Playback guarding, served-library inspection,
destination mutation, scanning, indexing, and visibility checks remain the
responsibility of the downstream promotion/library component and must be
reported back through the correlated operation record.

## Promotion destination discovery

External storage discovery begins only after an operator explicitly starts a
promotion. The promotion component may resolve the intended drive from the
Matrix node record or, when that record is unavailable or explicitly permits a
local fallback, from local `hv-cp` state. The Matrix node record is the
authoritative declaration; `hv-cp` is observed local state, not permission to
choose a different destination.

Resolution must produce an unambiguous stable drive identity, expected mount
target, destination root, source and observation time. Conflicting, stale,
missing, or multiply matching records fail closed and require operator action.
Before access, the promotion component must still use `findmnt -M` and verify
that the mounted filesystem and resolved drive identity agree. A path or node
record alone is never mount evidence.

Querying these records does not authorize the guest to attach a disk, change a
host mapping, mount an arbitrary device, or modify Matrix or hypervisor state.
Any such requirement crosses the guest authority boundary and must be reported
for host-side action.

## Governing rule

Local processing must remain fully useful with no external media mounts and no
Fastmail, Jellyfin, Matrix, or `hv-cp` availability. Communication and drive
resolution begin only for their explicitly requested downstream operations;
mount work begins only at the explicit promotion boundary.
