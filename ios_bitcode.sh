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
echo "target_os = ['ios']" >> .gclient
cd ~/v8/v8
git checkout refs/tags/$VERSION
gclient sync


echo "=====[ Patching V8 ]====="
# git apply --cached $GITHUB_WORKSPACE/patches/builtins-puerts.patches
node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/bitcode.patches

if [ "$VERSION" == "11.8.172" ]; then 
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/remove_uchar_include_v11.8.172.patch
  node $GITHUB_WORKSPACE/node-script/do-gitpatch.js -p $GITHUB_WORKSPACE/patches/enable_wee8_v11.8.172.patch
fi

echo "=====[ add ArrayBuffer_New_Without_Stl ]====="
node $GITHUB_WORKSPACE/node-script/add_arraybuffer_new_without_stl.js . $VERSION $NEW_WRAP

node $GITHUB_WORKSPACE/node-script/patchs.js . $VERSION $NEW_WRAP

echo "=====[ Building V8 ]====="

if [ "$VERSION" == "10.6.194" ]; then 
    gn gen out.gn/arm64.release --args="v8_use_external_startup_data=false v8_use_snapshot=true v8_enable_i18n_support=false is_debug=false v8_static_library=true ios_enable_code_signing=false target_os=\"ios\" target_cpu=\"arm64\" v8_enable_pointer_compression=false use_xcode_clang=true enable_ios_bitcode=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_sandbox=false use_custom_libcxx=false"
elif [ "$VERSION" == "11.8.172" ]; then
    gn gen out.gn/arm64.release --args="v8_use_external_startup_data=false v8_use_snapshot=true v8_enable_i18n_support=false is_debug=false v8_static_library=true ios_enable_code_signing=false target_os=\"ios\" target_cpu=\"arm64\" v8_enable_pointer_compression=false use_xcode_clang=true enable_ios_bitcode=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_sandbox=false use_custom_libcxx=false v8_enable_webassembly=false v8_enable_maglev=false v8_enable_webassembly=false"
else
    gn gen out.gn/arm64.release --args="v8_use_external_startup_data=false v8_use_snapshot=true v8_enable_i18n_support=false is_debug=false v8_static_library=true ios_enable_code_signing=false target_os=\"ios\" target_cpu=\"arm64\" v8_enable_pointer_compression=false use_xcode_clang=true enable_ios_bitcode=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false"
fi
ninja -C out.gn/arm64.release -t clean
mkdir -p output/v8/Lib/iOS/bitcode
ninja -v -C out.gn/arm64.release wee8
cp out.gn/arm64.release/obj/libwee8.a output/v8/Lib/iOS/bitcode/

mkdir -p output/v8/Inc/Blob/iOS/bitcode
