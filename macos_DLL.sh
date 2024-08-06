VERSION=$1
NEW_WRAP=$2
[ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE="$( cd "$( dirname "$0" )"/.. && pwd )"

cd ~
echo "=====[ Getting Depot Tools ]====="	
git clone -q https://chromium.googlesource.com/chromium/tools/depot_tools.git
cd depot_tools
git reset --hard 8d16d4a
cd ..
export DEPOT_TOOLS_UPDATE=0
export PATH=$(pwd)/depot_tools:$PATH
gclient


mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="
fetch v8
echo "target_os = ['mac']" >> .gclient
cd ~/v8/v8
git checkout refs/tags/$VERSION
gclient sync

# echo "=====[ Patching V8 ]====="
# git apply --cached $GITHUB_WORKSPACE/patches/builtins-puerts.patches
# git checkout -- .

if [ "$VERSION" == "11.8.172" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/remove_uchar_include_v11.8.172.patch
fi

#if [ "$NEW_WRAP" == "true" ]; then 
#  echo "=====[ wrap new delete ]====="
#  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/wrap_new_delete_v$VERSION.patch
#  brew install llvm
#  export PATH="/usr/local/opt/llvm/bin:$PATH"
#  llvm-objcopy --version
#fi

echo "=====[ add ArrayBuffer_New_Without_Stl ]====="
node $GITHUB_WORKSPACE/node-script/add_arraybuffer_new_without_stl.js .

node $GITHUB_WORKSPACE/node-script/patchs.js . $VERSION

echo "=====[ Building V8 ]====="

if [ "$VERSION" == "11.8.172" ]; then 
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false is_component_build=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false use_custom_libcxx=false v8_enable_maglev=false"
elif [ "$VERSION" == "10.6.194" ]; then
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false is_component_build=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false use_custom_libcxx=false"
else
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false is_component_build=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false"
fi

ninja -C out.gn/x64.release -t clean

#if [ "$NEW_WRAP" == "true" ]; then 
#  echo "=====[ add llvm-objcopy call to cxx ]====="
#  sed -i '' "/^rule cxx$/,/^ *command =/ s|\(command = .*\)|\1 \&\& llvm-objcopy --redefine-sym=__Znwm=___puerts_wrap__Znwm --redefine-sym=__ZdlPv=___puerts_wrap__ZdlPv --redefine-sym=__Znam=___puerts_wrap__Znam --redefine-sym=__ZdaPv=___puerts_wrap__ZdaPv --redefine-sym=__ZnwmRKSt9nothrow_t=___puerts_wrap__ZnwmRKSt9nothrow_t --redefine-sym=__ZnamRKSt9nothrow_t=___puerts_wrap__ZnamRKSt9nothrow_t \${out}|" "out.gn/x64.release/toolchain.ninja"
#fi
ninja -v -C out.gn/x64.release v8

mkdir -p output/v8/Lib/macOSdylib
cp out.gn/x64.release/libv8.dylib output/v8/Lib/macOSdylib/
cp out.gn/x64.release/libv8_libplatform.dylib output/v8/Lib/macOSdylib/
cp out.gn/x64.release/libv8_libbase.dylib output/v8/Lib/macOSdylib/
cp out.gn/x64.release/libchrome_zlib.dylib output/v8/Lib/macOSdylib/
if [ "$VERSION" == "11.8.172" ]; then
  cp out.gn/x64.release/libthird_party_abseil-cpp_absl.dylib output/v8/Lib/macOSdylib/
fi