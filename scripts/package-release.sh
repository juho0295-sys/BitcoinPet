#!/bin/zsh
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
version="${1:?Usage: zsh scripts/package-release.sh <version>}"
app_path="$project_root/dist/Bitcoin Pet.app"
archive_path="$project_root/dist/BitcoinPet-macOS-$version-universal.zip"

zsh "$project_root/scripts/build-app.sh"
ditto -c -k --sequesterRsrc --keepParent "$app_path" "$archive_path"
shasum -a 256 "$archive_path"
echo "$archive_path"
