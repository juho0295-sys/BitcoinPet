#!/bin/zsh
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root"

CLANG_MODULE_CACHE_PATH="$project_root/.build/module-cache" \
SWIFTPM_MODULECACHE_OVERRIDE="$project_root/.build/module-cache" \
swift build

product_dir="$project_root/.build/out/Products/Debug"
app_dir="$project_root/dist/Bitcoin Pet.app"
contents_dir="$app_dir/Contents"
mkdir -p "$contents_dir/MacOS" "$contents_dir/Resources"

cp "$product_dir/BitcoinPet" "$contents_dir/MacOS/BitcoinPet"
cp -R "$product_dir/BitcoinPet_BitcoinPet.bundle" "$contents_dir/Resources/"
cp "$project_root/AppBundle/Info.plist" "$contents_dir/Info.plist"
cp "$project_root/Resources/BitcoinPet.icns" "$contents_dir/Resources/BitcoinPet.icns"
codesign --force --sign - "$app_dir" >/dev/null
echo "$app_dir"
