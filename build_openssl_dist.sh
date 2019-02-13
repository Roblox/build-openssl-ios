#!/bin/bash

TMP_DIR=`pwd`/build_iOS-universal
CROSS_TOP_SIM="`xcode-select --print-path`/Platforms/iPhoneSimulator.platform/Developer"
CROSS_SDK_SIM="iPhoneSimulator.sdk"

CROSS_TOP_IOS="`xcode-select --print-path`/Platforms/iPhoneOS.platform/Developer"
CROSS_SDK_IOS="iPhoneOS.sdk"

export CROSS_COMPILE=`xcode-select --print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/

function build_for ()
{
  PLATFORM=$1
  ARCH=$2
  CROSS_TOP_ENV=CROSS_TOP_$3
  CROSS_SDK_ENV=CROSS_SDK_$3

  make clean

  export CROSS_TOP="${!CROSS_TOP_ENV}"
  export CROSS_SDK="${!CROSS_SDK_ENV}"
  ./Configure $PLATFORM "-arch $ARCH -fembed-bitcode -fno-omit-frame-pointer" no-ssl2 no-ssl3 no-dso no-engine no-async no-shared --prefix=${TMP_DIR}/${ARCH} || exit 1
  # problem of concurrent build; make -j8
  make && make install_sw || exit 2
  unset CROSS_TOP
  unset CROSS_SDK
}

function pack_for ()
{
  LIBNAME=$1
  mkdir -p ${TMP_DIR}/iOS-universal/lib/
  ${DEVROOT}/usr/bin/lipo \
	${TMP_DIR}/x86_64/lib/lib${LIBNAME}.a \
	${TMP_DIR}/armv7/lib/lib${LIBNAME}.a \
	${TMP_DIR}/arm64/lib/lib${LIBNAME}.a \
	-output ${TMP_DIR}/iOS-universal/lib/lib${LIBNAME}.a -create
}

curl -O https://raw.githubusercontent.com/Roblox/build-openssl-ios/master/patch-conf.patch
patch Configurations/10-main.conf < patch-conf.patch

build_for ios64sim-cross x86_64 SIM || exit 2
build_for ios-cross armv7 IOS || exit 4
build_for ios64-cross arm64 IOS || exit 5

pack_for ssl || exit 6
pack_for crypto || exit 7

cp -r ${TMP_DIR}/armv7/include ${TMP_DIR}/iOS-universal/
curl -O https://raw.githubusercontent.com/Roblox/build-openssl-ios/master/patch-include.patch
patch -p3 ${TMP_DIR}/iOS-universal/include/openssl/opensslconf.h < patch-include.patch
