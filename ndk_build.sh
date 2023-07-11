#!/bin/bash
set -e

cd "$(dirname "$0")"
rm -fr build
rm -fr out
mkdir out

if [ -z "$NDK" ]; then
    echo "\$NDK is not set"
    exit 1
else
    echo "\$NDK is set to $NDK"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

TARGET_ARRAY=("aarch64-linux-android" "armv7a-linux-androideabi" "x86_64-linux-android" "i686-linux-android")

for TARGET in "${TARGET_ARRAY[@]}"
do
export TARGET=$TARGET
export API=21
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

mkdir -p build/$TARGET
cd build/$TARGET

../../rsync/configure --host $TARGET --disable-openssl --disable-xxhash --disable-zstd --disable-lz4

CPU_COUNT=$(nproc)
make -j$CPU_COUNT
$STRIP rsync
cd ../..
cp build/$TARGET/rsync out/$TARGET-rsync

done
