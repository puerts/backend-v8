#!/bin/bash

VERSION=$1
[ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE="$( cd "$( dirname "$0" )"/.. && pwd )"

if [ "$VERSION" == "10.6.194" -o "$VERSION" == "11.8.172" ]; then 
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
if [ "$VERSION" != "10.6.194" -a "$VERSION" != "11.8.172" ]; then 
    cd depot_tools
    git reset --hard 8d16d4a
    cd ..
fi
export DEPOT_TOOLS_UPDATE=0
if [ "$VERSION" == "10.6.194" -o "$VERSION" == "11.8.172" ]; then 
    export PATH=$(pwd)/depot_tools:$PATH
else
    export PATH=$(pwd)/depot_tools:$(pwd)/depot_tools/.cipd_bin/2.7/bin:$PATH
fi
gclient


mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="
fetch v8
echo "target_os = ['linux']" >> .gclient
cd ~/v8/v8
git checkout refs/tags/$VERSION

if [ "$VERSION" == "11.8.172" ]; then 
  echo "=====[ Downgrade clang ]===="
  node -e "const fs = require('fs'); fs.writeFileSync('./DEPS', fs.readFileSync('./DEPS', 'utf-8').replace(/Var\('chromium_url'\) \+ '\/chromium\/src\/tools\/clang\.git' \+ '@' \+ '([a-f0-9]{40})'/, \"Var('chromium_url') + '/chromium/src/tools/clang.git' + '@' + '6a8e571efd68de48d226950d1e10cb8982e71496'\"));"
fi

gclient sync

if [ "$VERSION" == "11.8.172" ]; then
    wget https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/43a87bbebccad99325fdcf34166295b121ee15c7/debian_sid_amd64_sysroot.tar.xz
    mkdir -p build/linux/debian_sid_amd64-sysroot
    tar -xvJf debian_sid_amd64_sysroot.tar.xz -C build/linux/debian_sid_amd64-sysroot
    cd build
    node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/build_clang_14_v11.8.172.patch
    cd ../third_party/zlib
    node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/zlib_clang_14_v11.8.172.patch
    cd ../perfetto
    node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/perfetto_clang_14_v11.8.172.patch
    cd ../..
fi

# echo "=====[ Patching V8 ]====="
# git apply --cached $GITHUB_WORKSPACE/patches/builtins-puerts.patches
# git checkout -- .

if [ "$VERSION" == "11.8.172" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/remove_uchar_include_v11.8.172.patch
fi

echo "=====[ add ArrayBuffer_New_Without_Stl ]====="
node $GITHUB_WORKSPACE/node-script/add_arraybuffer_new_without_stl.js .

node $GITHUB_WORKSPACE/node-script/patchs.js . $VERSION

echo "=====[ Building V8 ]====="

if [ "$VERSION" == "11.8.172" ]; then 
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false use_custom_libcxx=false is_clang=true simple_template_names=false clang_use_chrome_plugins=false v8_enable_maglev=false"
elif [ "$VERSION" == "10.6.194"]; then 
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false use_custom_libcxx=false is_clang=true"
else
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false"
fi

ninja -C out.gn/x64.release -t clean
ninja -v -C out.gn/x64.release wee8

mkdir -p output/v8/Lib/Linux
cp out.gn/x64.release/obj/libwee8.a output/v8/Lib/Linux/
mkdir -p output/v8/Bin/Linux
find out.gn/ -type f -name v8cc -exec cp "{}" output/v8/Bin/Linux \;
find out.gn/ -type f -name mksnapshot -exec cp "{}" output/v8/Bin/Linux \;

