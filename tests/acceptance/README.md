# Acceptance tests

Acceptance promotes a deployed clone, not a template declaration. Run
`tests/acceptance/appliance --representative FILE --record RECORD`, after recording the manual gates
for bit depth, HDR/SDR, audio, subtitles, performance, thermals/hardware errors,
production command, and rollback. QSV is optional unless the private deployment
profile explicitly requires it. Begin from `record.example.yaml`; acceptance
refuses any gate that is not explicitly `passed`.
