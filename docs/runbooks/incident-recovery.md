# Incident recovery

Stop active work, preserve failed-job logs and raw evidence, and do not delete
input or partial output. Record device, package, mounts, free space, command,
and error with `bin/collect-evidence incident`. If a runtime change caused the
fault, reverse only that bounded transaction and rerun VA-API regression. Stop
without host changes if evidence points to passthrough, VFIO, IOMMU, or VM
hardware. Promotion resumes only after validation passes.

