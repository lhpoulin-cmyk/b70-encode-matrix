# b70-encode

This VM is solely a media-ingestion, analysis, transcoding, validation, and
pipeline-automation appliance for the Intel Arc Pro B70.

Production AV1 uses `xe → iHD → VA-API → av1_vaapi` on
`/dev/dri/renderD128`. QSV (`av1_qsv` through oneVPL) is experimental and must
never silently replace VA-API or fall back to software.

Operator commands are in `bin/`: run `bin/doctor` for a read-only state report,
`bin/probe INPUT` for JSON inspection, `bin/validate-output OUTPUT` for probe,
full decode and SHA-256, `bin/collect-evidence [label]` for a snapshot, and
`bin/encode MANIFEST` for a bounded manifest-driven encode. Smoke test with
`tests/smoke/vaapi-av1`.

Raw evidence is in `evidence/`; job transitions live in `jobs/`; bounded local
work is in `scratch/` and `tmp/`. External media may be mounted at
`/mnt/media/{source,work,output,archive}`, but these paths are never assumed to
be mounts. Originals are immutable and outputs are validated before promotion.
See `AGENTS.md` for safety boundaries and `docs/` for policies and runbooks.

