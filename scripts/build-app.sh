#!/bin/zsh
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root"

minimum_macos="14.0"
architectures=(arm64 x86_64)
product_dirs=()

for arch in "${architectures[@]}"; do
    scratch_path="$project_root/.build/distribution/$arch"
    module_cache="$scratch_path/module-cache"
    mkdir -p "$module_cache"

    CLANG_MODULE_CACHE_PATH="$module_cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$module_cache" \
        swift build \
            --configuration release \
            --triple "$arch-apple-macosx$minimum_macos" \
            --scratch-path "$scratch_path"

    product_dirs+=("$(swift build \
        --show-bin-path \
        --configuration release \
        --triple "$arch-apple-macosx$minimum_macos" \
        --scratch-path "$scratch_path")")
done

app_dir="$project_root/dist/Bitcoin Pet.app"
contents_dir="$app_dir/Contents"
mkdir -p "$contents_dir/MacOS" "$contents_dir/Resources"

cp -R "${product_dirs[1]}/BitcoinPet_BitcoinPet.bundle" "$contents_dir/Resources/"
cp "$project_root/AppBundle/Info.plist" "$contents_dir/Info.plist"
cp "$project_root/Resources/BitcoinPet.icns" "$contents_dir/Resources/BitcoinPet.icns"
lipo -create \
    "${product_dirs[1]}/BitcoinPet" \
    "${product_dirs[2]}/BitcoinPet" \
    -output "$contents_dir/MacOS/BitcoinPet"
codesign --force --sign - "$app_dir" >/dev/null
echo "$app_dir"
