#!/usr/bin/env bash

set -eu -o pipefail

INSTANCE_ID="$1"
INSTANCE_NAME="mm-ci-ubuntu-$INSTANCE_ID"

gcloud compute instances create "$INSTANCE_NAME" \
  --machine-type="n2-highcpu-64" \
  --image-project=ubuntu-os-cloud \
  --image-family=ubuntu-2604-lts-amd64 \
  --boot-disk-size=512GB \
  --enable-nested-virtualization \
  --zone=europe-west4-a
