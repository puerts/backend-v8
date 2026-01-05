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
if [ "$VERSION" != "9.4.146.24" ]; then 
    export PATH=$(pwd)/depot_tools:$PATH
else
    export PATH=$(pwd)/depot_tools:$(pwd)/depot_tools/.cipd_bin/2.7/bin:$PATH
fi
gclient
~/depot_tools/ensure_bootstrap


mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="
fetch v8
echo "target_os = ['linux']" >> .gclient
cd ~/v8/v8
git checkout refs/tags/$VERSION
gclient sync -D

# echo "=====[ Patching V8 ]====="
# git apply --cached $GITHUB_WORKSPACE/patches/builtins-puerts.patches
if [ "$VERSION" == "11.8.172" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/remove_uchar_include_v11.8.172.patch
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/enable_wee8_v11.8.172.patch
fi

if [ "$VERSION" == "12.9.202.27" -o "$VERSION" == "13.6.233.17" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/enable_wee8_v$VERSION.patch
fi

if [ "$VERSION" == "13.6.233.17" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/v8_monolithic_for_shared_library_flags_v13.6.233.17.patch
  cd build
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/turn_off_crel_v13.6.233.17.patch
  cd ..
fi

CXX_SETTING="use_custom_libcxx=false"

if [ "$NEW_WRAP" == "with_new_wrap" ]; then 
  echo "=====[ wrap new delete ]====="
  sudo apt-get install -y llvm
  CXX_SETTING="use_custom_libcxx=true"
elif [ "$VERSION" == "9.4.146.24" ]; then
  CXX_SETTING=""
fi

echo "=====[ add ArrayBuffer_New_Without_Stl ]====="
node $GITHUB_WORKSPACE/node-script/add_arraybuffer_new_without_stl.js . $VERSION $NEW_WRAP

node $GITHUB_WORKSPACE/node-script/patchs.js . $VERSION $NEW_WRAP

echo "=====[ Building V8 ]====="

if [ "$VERSION" == "9.4.146.24" ]; then
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false $CXX_SETTING"
elif [ "$VERSION" == "10.6.194" ]; then
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false $CXX_SETTING is_clang=true"
elif [ "$VERSION" == "11.8.172" ]; then
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false $CXX_SETTING is_clang=true v8_enable_maglev=false v8_enable_webassembly=false"
elif [ "$VERSION" == "12.9.202.27" ]; then
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false $CXX_SETTING is_clang=true v8_enable_maglev=false v8_enable_webassembly=false"
else
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false use_custom_libcxx=true is_clang=true v8_enable_maglev=false v8_enable_webassembly=false v8_monolithic=true v8_monolithic_for_shared_library=true"
fi

ninja -C out.gn/x64.release -t clean
ninja -v -C out.gn/x64.release wee8

mkdir -p output/v8/Lib/Linux
if [ "$NEW_WRAP" == "with_new_wrap" ]; then 
  bash $GITHUB_WORKSPACE/rename_symbols_posix.sh x64 output/v8/Lib/Linux/
fi
cp out.gn/x64.release/obj/libwee8.a output/v8/Lib/Linux/
mkdir -p output/v8/Bin/Linux
find out.gn/ -type f -name v8cc -exec cp "{}" output/v8/Bin/Linux \;
find out.gn/ -type f -name mksnapshot -exec cp "{}" output/v8/Bin/Linux \;

