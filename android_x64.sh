#!/bin/bash

VERSION=$1
NEW_WRAP=$2

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
export PATH=$(pwd)/depot_tools:$PATH
gclient


mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="
fetch v8
echo "target_os = ['android']" >> .gclient
cd ~/v8/v8
./build/install-build-deps-android.sh
git checkout refs/tags/$VERSION

echo "=====[ fix DEPS ]===="
node -e "const fs = require('fs'); fs.writeFileSync('./DEPS', fs.readFileSync('./DEPS', 'utf-8').replace(\"Var('chromium_url') + '/external/github.com/kennethreitz/requests.git'\", \"'https://github.com/kennethreitz/requests'\"));"

gclient sync


# echo "=====[ Patching V8 ]====="
# git apply --cached $GITHUB_WORKSPACE/patches/builtins-puerts.patches
# git checkout -- .

if [ "$VERSION" == "11.8.172" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/remove_uchar_include_v11.8.172.patch
fi

if [ "$NEW_WRAP" == "with_new_wrap" ]; then 
  echo "=====[ wrap new delete ]====="
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/wrap_new_delete_v$VERSION.patch
fi

echo "=====[ add ArrayBuffer_New_Without_Stl ]====="
node $GITHUB_WORKSPACE/node-script/add_arraybuffer_new_without_stl.js .

node $GITHUB_WORKSPACE/node-script/patchs.js . $VERSION $NEW_WRAP

echo "=====[ Building V8 ]====="
if [ "$VERSION" == "11.8.172" ]; then 
    gn gen out.gn/x64.release --args="target_os=\"android\" target_cpu=\"x64\" is_debug=false v8_enable_i18n_support=false v8_target_cpu=\"x64\" use_goma=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=false symbol_level=1 use_custom_libcxx=false use_custom_libcxx_for_host=true v8_enable_pointer_compression=false v8_enable_sandbox=false v8_enable_maglev=false"
elif [ "$VERSION" == "10.6.194" ]; then
    gn gen out.gn/x64.release --args="target_os=\"android\" target_cpu=\"x64\" is_debug=false v8_enable_i18n_support=false v8_target_cpu=\"x64\" use_goma=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=false symbol_level=1 use_custom_libcxx=false use_custom_libcxx_for_host=true v8_enable_pointer_compression=false v8_enable_sandbox=false"
else
    gn gen out.gn/x64.release --args="target_os=\"android\" target_cpu=\"x64\" is_debug=false v8_enable_i18n_support=false v8_target_cpu=\"x64\" use_goma=false v8_use_snapshot=true v8_use_external_startup_data=false v8_static_library=true strip_debug_info=false symbol_level=1 use_custom_libcxx=false use_custom_libcxx_for_host=true v8_enable_pointer_compression=false"
fi
ninja -C out.gn/x64.release -t clean
ninja -v -C out.gn/x64.release wee8
if [ "$VERSION" == "9.4.146.24" ]; then 
  third_party/android_ndk/toolchains/x86_64-4.9/prebuilt/linux-x86_64/x86_64-linux-android/bin/strip -g -S -d --strip-debug --verbose out.gn/x64.release/obj/libwee8.a
fi

mkdir -p output/v8/Lib/Android/x64
if [ "$NEW_WRAP" == "with_new_wrap" ]; then 
  third_party/android_ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-objcopy \
    --redefine-sym=_Znwm=__puerts_wrap__Znwm \
    --redefine-sym=_ZdlPv=__puerts_wrap__ZdlPv \
    --redefine-sym=_Znam=__puerts_wrap__Znam \
    --redefine-sym=_ZdaPv=__puerts_wrap__ZdaPv \
    --redefine-sym=_ZnwmRKSt9nothrow_t=__puerts_wrap__ZnwmRKSt9nothrow_t \
    --redefine-sym=_ZnamRKSt9nothrow_t=__puerts_wrap__ZnamRKSt9nothrow_t \
    --redefine-sym=_ZdaPvRKSt9nothrow_t=__puerts_wrap__ZdaPvRKSt9nothrow_t \
    --redefine-sym=_ZdaPvSt11align_val_t=__puerts_wrap__ZdaPvSt11align_val_t \
    --redefine-sym=_ZdaPvSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t \
    --redefine-sym=_ZdaPvm=__puerts_wrap__ZdaPvm \
    --redefine-sym=_ZdaPvmSt11align_val_t=__puerts_wrap__ZdaPvmSt11align_val_t \
    --redefine-sym=_ZdlPvRKSt9nothrow_t=__puerts_wrap__ZdlPvRKSt9nothrow_t \
    --redefine-sym=_ZdlPvSt11align_val_t=__puerts_wrap__ZdlPvSt11align_val_t \
    --redefine-sym=_ZdlPvSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t \
    --redefine-sym=_ZdlPvm=__puerts_wrap__ZdlPvm \
    --redefine-sym=_ZdlPvmSt11align_val_t=__puerts_wrap__ZdlPvmSt11align_val_t \
    --redefine-sym=_ZnamSt11align_val_t=__puerts_wrap__ZnamSt11align_val_t \
    --redefine-sym=_ZnamSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t \
    --redefine-sym=_ZnwmSt11align_val_t=__puerts_wrap__ZnwmSt11align_val_t \
    --redefine-sym=_ZnwmSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t \
    out.gn/x64.release/obj/libwee8.a
fi
cp out.gn/x64.release/obj/libwee8.a output/v8/Lib/Android/x64/
mkdir -p output/v8/Bin/Android/x64
find out.gn/ -type f -name v8cc -exec cp "{}" output/v8/Bin/Android/x64 \;
find out.gn/ -type f -name mksnapshot -exec cp "{}" output/v8/Bin/Android/x64 \;
