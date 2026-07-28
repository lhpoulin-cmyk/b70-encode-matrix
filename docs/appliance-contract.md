# GPU Encode Appliance Contract

Every deployed Helix-ARPA GPU encode appliance is the combination of a released
repository commit, a generic VM image, an active hardware profile, a private
deployment profile, passing acceptance evidence, and generated instance state.

## Identity

`BUILD` and `CURRENT_STATE.md` record appliance name and release, Git commit,
template version, hardware profile, deployment profile identifier, instance
hostname/name, and creation date. Values are supplied or observed; bootstrap
must not invent them.

## Required interface

Every instance provides executable `/srv/b70-encode/bin/{doctor,probe,encode,
validate-output,collect-evidence}` and the canonical `/srv/b70-encode`
workspace. `/mnt/media/{source,work,output,archive}` are reserved mount points;
existence is never treated as proof of a mount.

## Guarantees

- Original media is never overwritten and input/output paths differ.
- Incomplete output uses a temporary suffix and promotion follows validation.
- Hardware API, encoder, render node/device, and fallback policy are explicit.
- Software fallback is rejected unless a job explicitly authorizes it.
- Probe, required full decode, checksum, provenance, and logs gate promotion.
- Job evidence and failure reason are retained.
- The greater local reserve of 30 GiB or 20 percent is enforced.
- Guest logic never changes host GPU, storage, or virtualization configuration.

## Acceptance

Before promotion, tests prove expected physical GPU and kernel driver, render
node and access, userspace driver, required profile/encoder exposure, synthetic
hardware encode, intended hardware path in logs, valid probe, full decode,
SHA-256, no software fallback, MakeMKV when required, and observed
`CURRENT_STATE.md`. Representative-media gates add bit depth, HDR/SDR,
audio/subtitles, performance, thermals/errors, repetition, documented command,
and rollback. Optional experimental encoders are not acceptance gates unless
the private deployment profile requires them.
