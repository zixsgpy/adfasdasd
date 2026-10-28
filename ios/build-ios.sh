chmod +x ios/build-ios.sh
./ios/build-ios.sh#!/bin/sh
#
# Nightcord, a Discord client mod
# Copyright (c) 2026 Vendicated and contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
set -eu

cd "$(dirname "$0")/../.."
pnpm buildIOS

xcodebuild \
    -project ios/Nightcord/Nightcord.xcodeproj \
    -scheme Nightcord \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath build/Nightcord.xcarchive \
    archive

rm -rf build/ipa
mkdir -p build/ipa

xcodebuild \
    -exportArchive \
    -archivePath build/Nightcord.xcarchive \
    -exportPath build/ipa \
    -exportOptionsPlist ios/Nightcord/ExportOptions.plist

echo "IPA generated under build/ipa"
