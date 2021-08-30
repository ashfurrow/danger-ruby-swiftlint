#!/usr/bin/env bash
# frozen_string_literal: true

mkdir -p "${DESTINATION}"
curl -s -L "${URL}" -o "${ASSET}"
if [[ $(md5 -q "${ASSET}") != "${SWIFTLINT_MD5_HASH}" ]]; then
  echo "Zip was corrupted, try again later."
else
  unzip -o -q "${ASSET}" -d "${DESTINATION}"
fi
rm "${ASSET}"
