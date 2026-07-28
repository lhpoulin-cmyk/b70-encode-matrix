# Media policy

Originals are immutable: never overwrite, destructively rename, delete, or
modify them as part of encoding. Prefer read-only source mounts. Read source,
write a distinct work/output file, validate, then promote separately.

Without an explicit job policy, preserve audio, subtitles, chapters,
attachments, useful metadata, language tags, frame rate, HDR signalling, and
color metadata. Do not crop, resize, deinterlace, denoise, normalize audio,
burn subtitles, or discard alternate tracks.

Incomplete files use `.part`. Promotion requires FFmpeg success, nonempty
output, expected streams/codec, hardware-path evidence, FFprobe success, full
decode when required, checksum, and satisfaction of stream/metadata policy.
Promotion should be atomic on one filesystem. Deletion and archive decisions
remain separate operator actions.

