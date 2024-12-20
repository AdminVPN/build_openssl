#!/bin/bash

#set -v

if [[ -z "${ANDROID_NDK_HOME}" ]]; then
	# need change
	export ANDROID_NDK_HOME=~/Android/Sdk/ndk/28.0.12674087
else
	echo "Use environment variable ANDROID_NDK_HOME is: $ANDROID_NDK_HOME"
fi
sleep 3
# need change
export OPENSSL_VERSION="openssl-3.4.0"
curl -O "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz"

PROJECT_HOME=`pwd`
PATH_ORG=$PATH
OUTPUT_DIR="libs/android/clang"

# Clean output:
rm -rf $OUTPUT_DIR
sudo mkdir -p $OUTPUT_DIR

build_android_clang() {
	rm -rf ${OPENSSL_VERSION}
	tar xfz "${OPENSSL_VERSION}.tar.gz"

	echo ""
	echo "----- Build libcrypto & libssl.so for "$2" -----"
	echo ""

	ANDROID_API=$1
	CONFIGURE_PLATFORM=$2
	ARCHITECTURE=$CONFIGURE_PLATFORM

	# Clean openssl:
	cd "${OPENSSL_VERSION}"
	make clean

	# Build openssl libraries
	#perl -pi -w -e 's/\-mandroid//g;' ./Configure
	PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
	#turn off warning  macro-redefined
	# export CFLAGS="-Wno-macro-redefined -O3"
	./Configure  $CONFIGURE_PLATFORM -D__ANDROID_API__=$ANDROID_API shared threads no-asm no-sse2 no-ssl2 no-ssl3 no-comp no-hw no-engine
    
    make build_libs -j8
	sudo mkdir -p ../$OUTPUT_DIR/${ARCHITECTURE}/

    file libcrypto.so
    file libssl.so

    sudo cp libcrypto.a ../$OUTPUT_DIR/${ARCHITECTURE}/libcrypto.a
	sudo cp libssl.a ../$OUTPUT_DIR/${ARCHITECTURE}/libssl.a
	sudo cp libcrypto.so ../$OUTPUT_DIR/${ARCHITECTURE}/libcrypto.so
	sudo cp libssl.so ../$OUTPUT_DIR/${ARCHITECTURE}/libssl.so
	cd ..
}

# Build libcrypto for armeabi-v7a, x86 and arm64-v8a.
build_android_clang  "16"    	"android-arm"
build_android_clang  "16"    	"android-x86"
build_android_clang  "26"    	"android-arm64"

exit 0
