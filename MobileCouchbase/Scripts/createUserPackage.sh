#!/bin/sh

#calculate SDK version
SDK_VERSION=$(echo ${SDK_NAME} | grep -o '.\{3\}$')

#build iphone native first
SDK_TO_BUILD=iphoneos${SDK_VERSION}
ARCH="armv6 armv7"

xcodebuild -workspace "${SRCROOT}/../Couchbase.xcworkspace/" -scheme iErl14-iphoneos -configuration "${CONFIGURATION}" -sdk "${SDK_TO_BUILD}" -arch "${ARCH}" ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

xcodebuild -workspace "${SRCROOT}/../Couchbase.xcworkspace/" -scheme iMonkey-iphoneos -configuration "${CONFIGURATION}" -sdk "${SDK_TO_BUILD}" -arch "${ARCH}" ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

xcodebuild -workspace "${SRCROOT}/../Couchbase.xcworkspace/" -scheme Couchbase-iphoneos -configuration "${CONFIGURATION}" -sdk "${SDK_TO_BUILD}" -arch "${ARCH}" ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"


#now build iphone simulator
SDK_TO_BUILD=iphonesimulator${SDK_VERSION}
ARCH="i386"

xcodebuild -workspace "${SRCROOT}/../Couchbase.xcworkspace/" -scheme iErl14-iphonesimulator -configuration "${CONFIGURATION}" -sdk "${SDK_TO_BUILD}" -arch "${ARCH}" ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

xcodebuild -workspace "${SRCROOT}/../Couchbase.xcworkspace/" -scheme iMonkey-iphonesimulator -configuration "${CONFIGURATION}" -sdk "${SDK_TO_BUILD}" -arch "${ARCH}" ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

xcodebuild -workspace "${SRCROOT}/../Couchbase.xcworkspace/" -scheme Couchbase-iphonesimulator -configuration "${CONFIGURATION}" -sdk "${SDK_TO_BUILD}" -arch "${ARCH}" ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

#finally build the bundle

xcodebuild -workspace "${SRCROOT}/../Couchbase.xcworkspace/" -scheme Couchbase.bundle -configuration "${CONFIGURATION}" -sdk "${SDK_TO_BUILD}" -arch "${ARCH}" ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"


case $ACTION in
# NOTE: for some reason, it gets set to "" rather than "build" when
# doing a build.
"")

#now build fat binary
lipo -create -output ${BUILT_PRODUCTS_DIR}/libCouchbase.a ${BUILT_PRODUCTS_DIR}/libCouchbase-iphoneos.a ${BUILT_PRODUCTS_DIR}/libCouchbase-iphonesimulator.a

#now build zip file
cd ${BUILT_PRODUCTS_DIR}/;
zip -r iOSCouchbase.zip include/Couchbase.h Couchbase.bundle libCouchbase.a

;;

"clean")
# -f is required because it seems to call clean for all configurations (even ones you haven't built)
rm -f ${BUILT_PRODUCTS_DIR}/libCouchbase.a
rm -f ${BUILT_PRODUCTS_DIR}/iOSCouchbase.zip
;;
esac
