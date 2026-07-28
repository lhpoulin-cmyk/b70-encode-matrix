# Architecture

The controlled flow is:

```text
source → ingest → inspect → job manifest → hardware encode → probe
       → decode validation → checksum → output staging → promotion → evidence
```

Ingest never modifies originals. Inspection creates a machine-readable probe
and drives an explicit manifest. Encoding names the render node, API, and
encoder and writes a partial output. Probe, complete decode, and checksum gate
promotion. Evidence records commands, versions, logs, results, and provenance.

