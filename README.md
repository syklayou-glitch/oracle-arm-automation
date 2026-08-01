# Oracle ARM Capacity Automation

Sanitized baseline for periodically attempting an Oracle Cloud Always Free ARM instance launch.

Historical files in this directory contain tenancy/network identifiers and local OCI configuration, so the repository uses a default-deny `.gitignore`. Only reviewed templates are versioned.

Copy the example script and service definitions to a controlled host, provide the required `OCI_*` environment variables through a protected environment file, and validate with the OCI CLI before enabling the timer.

This automation may create a cloud instance. Keep the service disabled until its compartment, availability domain, subnet, source instance, shape, limits, and expected cost have been reviewed.

