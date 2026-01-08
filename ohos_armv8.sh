#!/bin/bash

VERSION=$1
NEW_WRAP=$2
[ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE="$( cd "$( dirname "$0" )"/.. && pwd )"

if [ "$VERSION" != "9.4.146.24" ]; then 
    sudo apt-get install -y \
        pkg-config \
        git \
        subversion \
        curl \
        wget \
        build-essential \
        python3 \
        ninja-build \
        xz-utils \
        zip
        
    pip install virtualenv
else
    sudo apt-get install -y \
        pkg-config \
        git \
        subversion \
        curl \
        wget \
        build-essential \
        python \
        xz-utils \
        zip
fi

cd ~
echo "=====[ Getting Depot Tools ]====="	
git clone -q https://chromium.googlesource.com/chromium/tools/depot_tools.git
if [ "$VERSION" == "9.4.146.24" ]; then 
    cd depot_tools
    git reset --hard 8d16d4a
    cd ..
fi
export DEPOT_TOOLS_UPDATE=0
export PATH=$(pwd)/depot_tools:$PATH
gclient
~/depot_tools/ensure_bootstrap


mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="
fetch v8
echo "target_os = ['android']" >> .gclient
cd ~/v8/v8
git checkout refs/tags/$VERSION

echo "=====[ fix DEPS ]===="
node -e "const fs = require('fs'); fs.writeFileSync('./DEPS', fs.readFileSync('./DEPS', 'utf-8').replace(\"Var('chromium_url') + '/external/github.com/kennethreitz/requests.git'\", \"'https://github.com/kennethreitz/requests'\"));"

gclient sync -D

if [ "$VERSION" == "9.4.146.24" ]; then 
    build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
fi

# echo "=====[ Patching V8 ]====="
# git apply --cached $GITHUB_WORKSPACE/patches/builtins-puerts.patches
# git checkout -- .

if [ "$VERSION" == "11.8.172" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/remove_uchar_include_v11.8.172.patch
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/enable_wee8_v11.8.172.patch
fi

if [ "$VERSION" == "12.9.202.27" -o "$VERSION" == "13.6.233.17" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/enable_wee8_v$VERSION.patch
fi

if [ "$VERSION" == "13.6.233.17" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/clang15_compatible_v13.6.233.17.patch
  cd build
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/turn_off_crel_v13.6.233.17.patch
  cd ..
fi

if [ "$VERSION" == "9.4.146.24" ]; then
  echo "=====[ patch jinja for python3.10+ ]====="
  cd third_party/jinja2
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/jinja_v9.4.146.24.patch
  cd ../..
fi

echo "=====[ patch for ohos ]====="
node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/ohos_v8_v$VERSION.patch
cd build
node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/ohos_build_v$VERSION.patch
cd ../third_party/zlib
node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/ohos_zlib_v$VERSION.patch
cd ../..

CXX_SETTING="use_custom_libcxx=false"

if [ "$NEW_WRAP" == "with_new_wrap" ]; then 
  echo "=====[ wrap new delete ]====="
  CXX_SETTING="use_custom_libcxx=true"
fi

echo "=====[ add ArrayBuffer_New_Without_Stl ]====="
node $GITHUB_WORKSPACE/node-script/add_arraybuffer_new_without_stl.js . $VERSION $NEW_WRAP

node $GITHUB_WORKSPACE/node-script/patchs.js . $VERSION $NEW_WRAP

rm -rf third_party/android_ndk
rm -rf third_party/icu

echo "=====[ Building V8 ]====="
if [ "$VERSION" == "9.4.146.24" ]; then
  gn gen --args="target_os=\"ohos\" target_cpu=\"arm64\" is_debug = false v8_enable_i18n_support= false v8_target_cpu = \"arm64\" use_goma = false v8_use_external_startup_data = false v8_static_library = true strip_debug_info=true symbol_level=0 $CXX_SETTING use_custom_libcxx_for_host=true v8_enable_pointer_compression=false use_musl=true" out.gn/arm64.release
elif [ "$VERSION" == "10.6.194" ]; then
  gn gen --args="target_os=\"ohos\" target_cpu=\"arm64\" is_debug = false v8_enable_i18n_support= false v8_target_cpu = \"arm64\" use_goma = false v8_use_external_startup_data = false v8_static_library = true strip_debug_info=true symbol_level=0 $CXX_SETTING use_custom_libcxx_for_host=true v8_enable_pointer_compression=false use_musl=true v8_enable_sandbox=false" out.gn/arm64.release
elif [ "$VERSION" == "11.8.172" ]; then
  gn gen --args="target_os=\"ohos\" target_cpu=\"arm64\" is_debug = false v8_enable_i18n_support= false v8_target_cpu = \"arm64\" use_goma = false v8_use_external_startup_data = false v8_static_library = true strip_debug_info=true symbol_level=0 $CXX_SETTING use_custom_libcxx_for_host=true v8_enable_pointer_compression=false use_musl=true v8_enable_sandbox=false v8_enable_maglev=false v8_enable_webassembly=false" out.gn/arm64.release
else
  gn gen --args="target_os=\"ohos\" target_cpu=\"arm64\" is_debug = false v8_enable_i18n_support= false v8_target_cpu = \"arm64\" use_goma = false v8_use_external_startup_data = false v8_static_library = true strip_debug_info=true symbol_level=0 $CXX_SETTING use_custom_libcxx_for_host=true v8_enable_pointer_compression=false use_musl=true v8_enable_sandbox=false v8_enable_maglev=false v8_enable_webassembly=false enable_rust=false" out.gn/arm64.release
fi
ninja -C out.gn/arm64.release -t clean
ninja -v -C out.gn/arm64.release wee8

mkdir -p output/v8/Lib/OHOS/arm64-v8a
if [ "$NEW_WRAP" == "with_new_wrap" ]; then
  export PATH="$OHOS_NDK_HOME/llvm/bin:$PATH"
  bash $GITHUB_WORKSPACE/rename_symbols_posix.sh arm64 output/v8/Lib/OHOS/arm64-v8a
fi
cp out.gn/arm64.release/obj/libwee8.a output/v8/Lib/OHOS/arm64-v8a/
mkdir -p output/v8/Bin/OHOS/arm64-v8a
find out.gn/ -type f -name v8cc -exec cp "{}" output/v8/Bin/OHOS/arm64-v8a \;
find out.gn/ -type f -name mksnapshot -exec cp "{}" output/v8/Bin/OHOS/arm64-v8a \;
