VERSION=$1
[ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE="$( cd "$( dirname "$0" )"/.. && pwd )"

cd ~
echo "=====[ Getting Depot Tools ]====="	
git clone -q https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$(pwd)/depot_tools:$PATH
gclient


mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="
fetch v8
echo "target_os = ['mac-arm64']" >> .gclient
cd ~/v8/v8
git checkout refs/tags/$VERSION
gclient sync

# echo "=====[ Patching V8 ]====="
# git apply --cached $GITHUB_WORKSPACE/patch/builtins-puerts.patch
# git checkout -- .

echo "=====[ Building V8 ]====="
python ./tools/dev/v8gen.py arm64.release -vv -- '
is_debug = false
target_cpu = "arm64"
v8_target_cpu = "arm64"
v8_enable_i18n_support= false
v8_use_snapshot = true
v8_use_external_startup_data = true
v8_static_library = true
strip_debug_info = true
symbol_level=0
libcxx_abi_unstable = false
v8_enable_pointer_compression=false
'
ninja -C out.gn/arm64.release -t clean
ninja -C out.gn/arm64.release wee8

node $GITHUB_WORKSPACE/genBlobHeader.js "osx 64" out.gn/arm64.release/snapshot_blob.bin

mkdir -p output/v8/Lib/macOS_arm64
cp out.gn/arm64.release/obj/libwee8.a output/v8/Lib/macOS_arm64/
mkdir -p output/v8/Inc/Blob/macOS_arm64
cp SnapshotBlob.h output/v8/Inc/Blob/macOS_arm64/
