#!/usr/bin/env bash

### Load arguments
while [[ $# > 0 ]]
do
    case "$1" in
        -u|--url)
            url="$2"
            shift;;

        -d|--destination)
            destination="$2"
            shift;;

        -a|--asset)
            asset="$2"
            shift;;

        -dh|--default_hash)
            default_hash="$2"
            shift;;

        --help|*)
            echo "Usage:"
            echo ' -u --url: URL for SwiftLint version to download'
            echo ' -d --destination: Folder where SwiftLint will be downloaded'
            echo " -a --asset: Temporary name for the zip file"
            echo " -dh --default_hash: Default SwiftLint md5 hash to check for if no version specified"
            exit 1;;
    esac
    shift
done

### Download
mkdir -p "${destination}"
curl -s -L "${url}" -o "${asset}"

# If macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
   resulting_hash=`md5 -q ${asset}`
# Default to linux
else
   resulting_hash=`md5sum ${asset} | awk '{ print $1 }'`
fi

if [[ ! -z "${SWIFTLINT_VERSION}" || "$resulting_hash" == "${default_hash}" ]]; then
  # if another version is set || our hardcoded hash is correct
  unzip -o -q "${asset}" -d "${destination}"
else
  echo "Zip was corrupted, try again later."
fi
rm "${asset}"
