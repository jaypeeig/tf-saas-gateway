#!/bin/bash
find . -name package.json \
  \( ! -path "*/node_modules/*" -a ! -path "*/.terraform/*" \) \
  -execdir npm i \;

terraform apply --auto-approve
