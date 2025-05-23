#!/bin/bash

# 環境に応じてGoogleService-Info.plistをコピーするスクリプト
echo "Selecting GoogleService-Info.plist for ${CONFIGURATION}"

if [ "${CONFIGURATION}" = "Debug" ]; then
    echo "Using Debug GoogleService-Info.plist"
    cp "${PROJECT_DIR}/FirebaseConfigs/Debug/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
elif [ "${CONFIGURATION}" = "Release" ]; then
    echo "Using Release GoogleService-Info.plist"
    cp "${PROJECT_DIR}/FirebaseConfigs/Release/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
else
    echo "Configuration ${CONFIGURATION} not recognized, using default GoogleService-Info.plist"
    cp "${PROJECT_DIR}/Runner/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
fi

echo "GoogleService-Info.plist copied successfully." 