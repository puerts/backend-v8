import os
import subprocess
import shutil
import sys

VERSION = sys.argv[1] # expected version of v8
PLATFORM = sys.argv[2]
ARCH = sys.argv[3]
__DIRNAME = os.path.dirname(os.path.abspath(__file__))

os.chdir(os.path.expanduser("~"))

print("=====[ Getting Depot Tools ]=====")
subprocess.run(['git', 'clone', 'https://chromium.googlesource.com/chromium/tools/depot_tools.git'])

os.chdir('depot_tools')
subprocess.run(['git', 'reset', '--hard', '8d16d4a'])
os.chdir('..')

os.environ['DEPOT_TOOLS_UPDATE'] = '0'
os.environ['PATH'] = os.path.join(os.getcwd(), 'depot_tools') + ':' + os.environ['PATH']

subprocess.run(['gclient'])

os.makedirs('v8', exist_ok=True)
os.chdir('v8')

print("=====[ Fetching V8 ]=====")
subprocess.run(['fetch', 'v8'])

if PLATFORM == 'android':
    with open('.gclient', 'a') as f:
        f.write('\ntarget_os = [\'android\']\n')

os.chdir(os.path.join(os.getcwd(), 'v8'))
subprocess.run(['git', 'checkout', 'refs/tags/' + VERSION])

print("=====[ fix DEPS ]====")
cmd = "const fs = require('fs'); fs.writeFileSync('./DEPS', fs.readFileSync('./DEPS', 'utf-8').replace(\"Var('chromium_url') + '/external/github.com/kennethreitz/requests.git'\", \"'https://github.com/kennethreitz/requests'\"));"
subprocess.run(['node', '-e', cmd])

subprocess.run(['gclient', 'sync'])

print("=====[ add ArrayBuffer_New_Without_Stl ]=====")
script_path = os.path.join(__DIRNAME, 'node-script', 'add_arraybuffer_new_without_stl.js')
subprocess.run(['node', script_path])

if PLATFORM == "linux" and ARCH=="arm64":
    subprocess.run(['python', "build/linux/sysroot_scripts/install-sysroot.py", "--arch=arm64"])

print("=====[ Building V8 ]=====")
v8gen_args = [
    'is_debug = false',
    'v8_enable_i18n_support= false',
    'use_goma = false',
    'v8_use_snapshot = true',
    'v8_use_external_startup_data = true',
    'v8_static_library = true',
    'strip_absolute_paths_from_debug_symbols = false',
    'strip_debug_info = false',
    'symbol_level=0',
]
v8gen_base = 'x64.release'
if PLATFORM == 'android':
    v8gen_args.append('target_os = "android"')
elif PLATFORM == 'linux':
    v8gen_args.append('libcxx_abi_unstable = false')
    v8gen_args.append('v8_enable_pointer_compression=false')

if ARCH == 'armv7':
    v8gen_args.append('target_cpu = "arm"')
    v8gen_args.append('v8_target_cpu = "arm"')
    v8gen_base = 'arm.release'
elif ARCH == 'arm64':
    v8gen_args.append('target_cpu = "arm64"')
    v8gen_args.append('v8_target_cpu = "arm64"')
    v8gen_base = 'arm64.release'
elif ARCH == 'x64':
    v8gen_args.append('target_cpu = "x64"')
    v8gen_args.append('v8_target_cpu = "x64"')
    v8gen_base = 'x64.release'
    
v8gen_args = [v8gen_base, '-vv', '--', '\n'.join(v8gen_args)] 

v8gen_script_path = os.path.join(os.getcwd(), 'tools', 'dev', 'v8gen.py')
subprocess.run(['python', v8gen_script_path] + v8gen_args)


ninja_clean_cmd = ['ninja', '-C', 'out.gn/' + v8gen_base, '-t', 'clean']
subprocess.run(ninja_clean_cmd)

ninja_wee8_cmd = ['ninja', '-C', 'out.gn/' + v8gen_base, 'wee8']
subprocess.run(ninja_wee8_cmd)

if PLATFORM == 'android':
    if ARCH == 'armv7':
        strip_cmd = ['third_party/android_ndk/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin/strip', '-g', '-S', '-d', '--strip-debug', '--verbose', 'out.gn/arm.release/obj/libwee8.a']
    if ARCH == 'arm64':
        strip_cmd = ['third_party/android_ndk/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/aarch64-linux-android/bin/strip', '-g', '-S', '-d', '--strip-debug', '--verbose', 'out.gn/arm64.release/obj/libwee8.a']
    if ARCH == 'x64':
        strip_cmd = ['third_party/android_ndk/toolchains/x86_64-4.9/prebuilt/linux-x86_64/x86_64-linux-android/bin/strip', '-g', '-S', '-d', '--strip-debug', '--verbose', 'out.gn/x64.release/obj/libwee8.a']
        
    subprocess.run(strip_cmd)
    
blob_header_script_path = os.path.join(__DIRNAME, 'node-script', 'genBlobHeader.js')
blob_header_args = [PLATFORM + " " + ARCH, "out.gn/" + v8gen_base + "/snapshot_blob.bin"]
subprocess.run(['node', blob_header_script_path] + blob_header_args)

if PLATFORM == 'android':
    if ARCH == 'armv7':
        os.makedirs('output/v8/Lib/Android/armeabi-v7a', exist_ok=True)
        os.makedirs('output/v8/Inc/Blob/Android/armv7a', exist_ok=True)
        shutil.copy('out.gn/arm.release/obj/libwee8.a', 'output/v8/Lib/Android/armeabi-v7a/')
        shutil.copy('SnapshotBlob.h', 'output/v8/Inc/Blob/Android/armv7a/')
    if ARCH == 'arm64':
        os.makedirs('output/v8/Lib/Android/arm64-v8a', exist_ok=True)
        os.makedirs('output/v8/Inc/Blob/Android/arm64', exist_ok=True)
        shutil.copy('out.gn/arm64.release/obj/libwee8.a', 'output/v8/Lib/Android/arm64-v8a/')
        shutil.copy('SnapshotBlob.h', 'output/v8/Inc/Blob/Android/arm64/')
    if ARCH == 'x64':
        os.makedirs('output/v8/Lib/Android/x64', exist_ok=True)
        os.makedirs('output/v8/Inc/Blob/Android/x64', exist_ok=True)
        shutil.copy('out.gn/x64.release/obj/libwee8.a', 'output/v8/Lib/Android/x64/')
        shutil.copy('SnapshotBlob.h', 'output/v8/Inc/Blob/Android/x64/')
if PLATFORM == 'linux':
    if ARCH == 'arm64':
        os.makedirs('output/v8/Lib/Linux_arm64', exist_ok=True)
        os.makedirs('output/v8/Inc/Blob/Linux_arm64', exist_ok=True)
        shutil.copy('out.gn/arm64.release/obj/libwee8.a', 'output/v8/Lib/Linux_arm64/')
        shutil.copy('SnapshotBlob.h', 'output/v8/Inc/Blob/Linux_arm64/')
    if ARCH == 'x64':
        os.makedirs('output/v8/Lib/Linux', exist_ok=True)
        os.makedirs('output/v8/Inc/Blob/Linux', exist_ok=True)
        shutil.copy('out.gn/x64.release/obj/libwee8.a', 'output/v8/Lib/Linux/')
        shutil.copy('SnapshotBlob.h', 'output/v8/Inc/Blob/Linux/')
        
