param (
    [string]$VERSION
)

cd ~
Write-Host "=====[ Getting Depot Tools ]====="
Invoke-WebRequest -Uri "https://storage.googleapis.com/chrome-infra/depot_tools.zip" -OutFile "depot_tools.zip"
7z x depot_tools.zip -o*
$env:PATH = "$PWD\depot_tools;$env:PATH"
$env:GYP_MSVS_VERSION = "2019"
$env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
& gclient

cd depot_tools
& git reset --hard 8d16d4a
cd ..
$env:DEPOT_TOOLS_UPDATE = "0"

mkdir v8
cd v8

Write-Host "=====[ Fetching V8 ]====="
& fetch v8
cd v8
& git checkout "refs/tags/$VERSION"
# cd test\test262\data
& git config --system core.longpaths true
# & git restore *
# cd ..\..\..\
& gclient sync

# Write-Host "=====[ Patching V8 ]====="
# node $env:GITHUB_WORKSPACE\CRLF2LF.js $env:GITHUB_WORKSPACE\patches\builtins-puerts.patches
# & git apply --cached --reject $env:GITHUB_WORKSPACE\patches\builtins-puerts.patches
# & git checkout -- .

if ($VERSION -eq "10.6.194") {
    Write-Host "=====[ patch 10.6.194 ]====="
    node "$PSScriptRoot\node-script\do-gitpatch.js" -p "$env:GITHUB_WORKSPACE\patches\win_msvc_v10.6.194.patch"
}

if ($VERSION -eq "11.8.172") {
    Write-Host "=====[ patch 11.8.172 ]====="
    node "$PSScriptRoot\node-script\do-gitpatch.js" -p "$env:GITHUB_WORKSPACE\patches\remove_uchar_include_v11.8.172.patch"
    node "$PSScriptRoot\node-script\do-gitpatch.js" -p "$env:GITHUB_WORKSPACE\patches\win_dll_v11.8.172.patch"
}

if ($VERSION -eq "9.4.146.24") {
    Write-Host "=====[ patch jinja for python3.10+ ]====="
    cd third_party\jinja2
    node "$PSScriptRoot\node-script\do-gitpatch.js" -p "$env:GITHUB_WORKSPACE\patches\jinja_v9.4.146.24.patch"
    cd ..\..
}

Write-Host "=====[ Make dynamic_crt ]====="
node "$PSScriptRoot\node-script\rep.js" build\config\win\BUILD.gn

Write-Host "=====[ commenting out Zc_inline ]====="
node -e "const fs = require('fs'); fs.writeFileSync('./build/config/compiler/BUILD.gn', fs.readFileSync('./build/config/compiler/BUILD.gn', 'utf-8').replace('\"/Zc:inline\"', '#\"/Zc:inline\"'));"

Write-Host "=====[ add ArrayBuffer_New_Without_Stl ]====="
node "$PSScriptRoot\node-script\add_arraybuffer_new_without_stl.js" .

node "$PSScriptRoot\node-script\patchs.js" . $VERSION

Write-Host "=====[ Building V8 ]====="
if ($VERSION -eq "10.6.194" -or $VERSION -eq "11.8.172") {
    $args = 'target_os=\"win\" target_cpu=\"x64\" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false is_component_build=true v8_enable_sandbox=false'
} else {
    $args = 'target_os=\"win\" target_cpu=\"x64\" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false is_component_build=true'
}
& gn gen out.gn\x64.release "--args=$args"
& ninja -C out.gn\x64.release -t clean
& ninja -v -C out.gn\x64.release v8

mkdir -Force output\v8\Lib\Win64DLL
Copy-Item -Force out.gn\x64.release\v8.dll.lib output\v8\Lib\Win64DLL\
Copy-Item -Force out.gn\x64.release\v8_libplatform.dll.lib output\v8\Lib\Win64DLL\
Copy-Item -Force out.gn\x64.release\v8.dll output\v8\Lib\Win64DLL\
Copy-Item -Force out.gn\x64.release\v8_libbase.dll output\v8\Lib\Win64DLL\
Copy-Item -Force out.gn\x64.release\v8_libplatform.dll output\v8\Lib\Win64DLL\
Copy-Item -Force out.gn\x64.release\zlib.dll output\v8\Lib\Win64DLL\
Copy-Item -Force out.gn\x64.release\v8.dll.pdb output\v8\Lib\Win64DLL\
Copy-Item -Force out.gn\x64.release\v8_libbase.dll.pdb output\v8\Lib\Win64DLL\
Copy-Item -Force out.gn\x64.release\v8_libplatform.dll.pdb output\v8\Lib\Win64DLL\
Copy-Item -Force out.gn\x64.release\zlib.dll.pdb output\v8\Lib\Win64DLL\
