#!/bin/bash
set -euo pipefail

FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
GEO_FRAMEWORK="${FRAMEWORKS_DIR}/GeoComplySDK.framework"
GEO_BINARY="${GEO_FRAMEWORK}/GeoComplySDK"

rm -rf "${GEO_FRAMEWORK}"
mkdir -p "${GEO_FRAMEWORK}"

STUB_ROOT="${DERIVED_FILE_DIR}/GeoComplySDKStub"
mkdir -p "${STUB_ROOT}"

SRC_FILE="${STUB_ROOT}/GeoComplyClient.m"
cat > "${SRC_FILE}" <<'EOF'
#import <Foundation/Foundation.h>

@interface GeoComplyClient : NSObject
@end

@implementation GeoComplyClient
@end

@interface GCReasonCode : NSObject
@end

@implementation GCReasonCode
@end

__attribute__((constructor))
static void GeoComplySDKForceClassLinking(void) {
  [GeoComplyClient class];
  [GCReasonCode class];
}
EOF

ARCH_LIST="${ARCHS:-${CURRENT_ARCH:-arm64}}"
STUB_BINS=()

for ARCH in ${ARCH_LIST}; do
  OUT_FILE="${STUB_ROOT}/GeoComplySDK-${ARCH}"
  /usr/bin/xcrun clang \
    -dynamiclib \
    -fobjc-arc \
    -isysroot "${SDKROOT}" \
    -arch "${ARCH}" \
    -install_name "@rpath/GeoComplySDK.framework/GeoComplySDK" \
    "${SRC_FILE}" \
    -framework Foundation \
    -current_version 1.0.0 \
    -compatibility_version 1.0.0 \
    -o "${OUT_FILE}"
  STUB_BINS+=("${OUT_FILE}")
done

if [ "${#STUB_BINS[@]}" -gt 1 ]; then
  /usr/bin/lipo -create "${STUB_BINS[@]}" -output "${GEO_BINARY}"
else
  /bin/cp "${STUB_BINS[0]}" "${GEO_BINARY}"
fi

cat > "${GEO_FRAMEWORK}/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>GeoComplySDK</string>
  <key>CFBundleIdentifier</key>
  <string>com.arrowfun.geocomplysdk.stub</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
</dict>
</plist>
EOF

if [ "${CODE_SIGNING_ALLOWED:-NO}" != "NO" ] && [ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" ]; then
  /usr/bin/codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements "${GEO_FRAMEWORK}"
fi
