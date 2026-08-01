#!/usr/bin/env bash
set -euo pipefail

: "${OCI_COMPARTMENT_ID:?set OCI_COMPARTMENT_ID}"
: "${OCI_AVAILABILITY_DOMAIN:?set OCI_AVAILABILITY_DOMAIN}"
: "${OCI_SUBNET_ID:?set OCI_SUBNET_ID}"
: "${OCI_SOURCE_INSTANCE_ID:?set OCI_SOURCE_INSTANCE_ID}"

display_name="${OCI_DISPLAY_NAME:-arm-free-instance}"

existing_states="$({
  oci compute instance list \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --display-name "$display_name" \
    --all \
    --output json
} | python3 -c 'import json,sys; data=json.load(sys.stdin)["data"]; print(",".join(x.get("lifecycle-state", "UNKNOWN") for x in data if x.get("lifecycle-state") != "TERMINATED"))')"

if [[ -n "$existing_states" ]]; then
  echo "An active instance named $display_name already exists (state: $existing_states)."
  exit 0
fi

image_id="$(oci compute image list \
  --compartment-id "$OCI_COMPARTMENT_ID" \
  --shape "VM.Standard.A1.Flex" \
  --operating-system "Canonical Ubuntu" \
  --operating-system-version "24.04" \
  --sort-by TIMECREATED \
  --sort-order DESC \
  --all \
  --query 'data[0].id' \
  --raw-output)"

ssh_key="$(oci compute instance get \
  --instance-id "$OCI_SOURCE_INSTANCE_ID" \
  --query 'data.metadata."ssh_authorized_keys"' \
  --raw-output)"

metadata_file="$(mktemp)"
source_file="$(mktemp)"
trap 'rm -f "$metadata_file" "$source_file"' EXIT

SSH_KEY="$ssh_key" python3 -c \
  'import json,os,sys; json.dump({"ssh_authorized_keys": os.environ["SSH_KEY"]}, sys.stdout)' \
  > "$metadata_file"
IMAGE_ID="$image_id" python3 -c \
  'import json,os,sys; json.dump({"sourceType":"image","imageId":os.environ["IMAGE_ID"],"bootVolumeSizeInGBs":100}, sys.stdout)' \
  > "$source_file"

oci compute instance launch \
  --availability-domain "$OCI_AVAILABILITY_DOMAIN" \
  --compartment-id "$OCI_COMPARTMENT_ID" \
  --display-name "$display_name" \
  --shape "VM.Standard.A1.Flex" \
  --shape-config '{"ocpus":2,"memoryInGBs":12}' \
  --source-details "file://$source_file" \
  --subnet-id "$OCI_SUBNET_ID" \
  --assign-public-ip true \
  --metadata "file://$metadata_file" \
  --wait-for-state RUNNING \
  --max-wait-seconds 900 \
  --output json

