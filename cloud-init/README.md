# Cloud-init examples

These files are sanitized contracts, not deployable secrets. Replace every
angle-bracket placeholder in a private deployment system. Cloud-init establishes
identity, operator access, checkout, and generic bootstrap. It deliberately
does not validate a GPU; attach the resource, complete any required reboot, then
run `bootstrap/finalize-instance.sh` and acceptance tests.
