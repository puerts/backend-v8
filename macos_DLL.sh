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

CXX_SETTING="use_custom_libcxx=false"

if [ "$NEW_WRAP" == "with_new_wrap" ]; then 
  echo "=====[ wrap new delete ]====="
  brew install llvm
  export PATH="/usr/local/opt/llvm/bin:$PATH"
  CXX_SETTING="use_custom_libcxx=true libcxx_is_shared=false"
elif [ "$VERSION" == "9.4.146.24" ]; then
  CXX_SETTING=""
fi

echo "=====[ add ArrayBuffer_New_Without_Stl ]====="
node $GITHUB_WORKSPACE/node-script/add_arraybuffer_new_without_stl.js . $VERSION $NEW_WRAP

node $GITHUB_WORKSPACE/node-script/patchs.js . $VERSION $NEW_WRAP

echo "=====[ Building V8 ]====="

if [ "$VERSION" == "11.8.172" ]; then 
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false is_component_build=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false $CXX_SETTING v8_enable_maglev=false v8_enable_webassembly=false"
elif [ "$VERSION" == "10.6.194" ]; then
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false is_component_build=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false v8_enable_sandbox=false $CXX_SETTING"
else
    gn gen out.gn/x64.release --args="is_debug=false v8_enable_i18n_support=false v8_use_snapshot=true v8_use_external_startup_data=false is_component_build=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false v8_enable_pointer_compression=false  $CXX_SETTING"
fi

ninja -C out.gn/x64.release -t clean

if [ "$NEW_WRAP" == "with_new_wrap" ]; then 
  echo "=====[ add llvm-objcopy call to cxx ]====="
  sed -i '' "/^rule cxx$/,/^ *command =/ s|\(command = .*\)|\1 \&\& llvm-objcopy --redefine-sym=__Znwm=___puerts_wrap__Znwm --redefine-sym=__ZdlPv=___puerts_wrap__ZdlPv --redefine-sym=__Znam=___puerts_wrap__Znam --redefine-sym=__ZdaPv=___puerts_wrap__ZdaPv --redefine-sym=__ZnwmRKSt9nothrow_t=___puerts_wrap__ZnwmRKSt9nothrow_t --redefine-sym=__ZnamRKSt9nothrow_t=___puerts_wrap__ZnamRKSt9nothrow_t --redefine-sym=__ZdaPvRKSt9nothrow_t=___puerts_wrap__ZdaPvRKSt9nothrow_t --redefine-sym=__ZdaPvSt11align_val_t=___puerts_wrap__ZdaPvSt11align_val_t --redefine-sym=__ZdaPvSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t --redefine-sym=__ZdaPvm=___puerts_wrap__ZdaPvm --redefine-sym=__ZdaPvmSt11align_val_t=___puerts_wrap__ZdaPvmSt11align_val_t --redefine-sym=__ZdlPvRKSt9nothrow_t=___puerts_wrap__ZdlPvRKSt9nothrow_t --redefine-sym=__ZdlPvSt11align_val_t=___puerts_wrap__ZdlPvSt11align_val_t --redefine-sym=__ZdlPvSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t --redefine-sym=__ZdlPvm=___puerts_wrap__ZdlPvm --redefine-sym=__ZdlPvmSt11align_val_t=___puerts_wrap__ZdlPvmSt11align_val_t --redefine-sym=__ZnamSt11align_val_t=___puerts_wrap__ZnamSt11align_val_t --redefine-sym=__ZnamSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t --redefine-sym=__ZnwmSt11align_val_t=___puerts_wrap__ZnwmSt11align_val_t --redefine-sym=__ZnwmSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t --redefine-sym=__ZNKSt16nested_exception14rethrow_nestedEv=___ZNKSt16nested_exception14rethrow_nestedEv --redefine-sym=__ZNSt13exception_ptrC1ERKS_=___ZNSt13exception_ptrC1ERKS_ --redefine-sym=__ZNSt13exception_ptrC2ERKS_=___ZNSt13exception_ptrC2ERKS_ --redefine-sym=__ZNSt13exception_ptrD1Ev=___ZNSt13exception_ptrD1Ev --redefine-sym=__ZNSt13exception_ptrD2Ev=___ZNSt13exception_ptrD2Ev --redefine-sym=__ZNSt13exception_ptraSERKS_=___ZNSt13exception_ptraSERKS_ --redefine-sym=__ZNSt16nested_exceptionC1Ev=___ZNSt16nested_exceptionC1Ev --redefine-sym=__ZNSt16nested_exceptionC2Ev=___ZNSt16nested_exceptionC2Ev --redefine-sym=__ZNSt16nested_exceptionD0Ev=___ZNSt16nested_exceptionD0Ev --redefine-sym=__ZNSt16nested_exceptionD1Ev=___ZNSt16nested_exceptionD1Ev --redefine-sym=__ZNSt16nested_exceptionD2Ev=___ZNSt16nested_exceptionD2Ev --redefine-sym=__ZSt17current_exceptionv=___ZSt17current_exceptionv --redefine-sym=__ZSt17rethrow_exceptionSt13exception_ptr=___ZSt17rethrow_exceptionSt13exception_ptr --redefine-sym=__ZSt18uncaught_exceptionv=___ZSt18uncaught_exceptionv --redefine-sym=__ZSt19uncaught_exceptionsv=___ZSt19uncaught_exceptionsv \${out}|" "out.gn/x64.release/toolchain.ninja"
fi
ninja -v -C out.gn/x64.release v8

mkdir -p output/v8/Lib/macOSdylib
cp out.gn/x64.release/libv8.dylib output/v8/Lib/macOSdylib/
cp out.gn/x64.release/libv8_libplatform.dylib output/v8/Lib/macOSdylib/
cp out.gn/x64.release/libv8_libbase.dylib output/v8/Lib/macOSdylib/
cp out.gn/x64.release/libchrome_zlib.dylib output/v8/Lib/macOSdylib/
if [ "$VERSION" == "11.8.172" ]; then
  cp out.gn/x64.release/libthird_party_abseil-cpp_absl.dylib output/v8/Lib/macOSdylib/
fi

if [ "$NEW_WRAP" == "with_new_wrap" ]; then 
  if [ -f "out.gn/x64.release/libc++_chrome.dylib" ]; then
    cp out.gn/x64.release/libc++_chrome.dylib output/v8/Lib/macOSdylib/
  fi
fi
