param (
    [string]$VERSION
)

cd ~
Write-Output "=====[ Getting Depot Tools ]====="
Invoke-WebRequest -Uri "https://storage.googleapis.com/chrome-infra/depot_tools.zip" -OutFile "depot_tools.zip"
Expand-Archive -Path "depot_tools.zip" -DestinationPath "."
$env:PATH = "$PWD\depot_tools;$env:PATH"
$env:GYP_MSVS_VERSION = "2019"
$env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
& gclient

cd depot_tools
& git reset --hard 8d16d4a
cd ..
$env:DEPOT_TOOLS_UPDATE = "0"

New-Item -ItemType Directory -Name "v8"
cd v8

Write-Output "=====[ Fetching V8 ]====="
& fetch v8
cd v8
& git checkout "refs/tags/$VERSION"
& git config --system core.longpaths true
& gclient sync

if ($VERSION -eq "9.4.146.24") {
    Write-Output "=====[ patch jinja for python3.10+ ]====="
    cd third_party\jinja2
    node "$PSScriptRoot\node-script\do-gitpatch.js" -p "$env:GITHUB_WORKSPACE\patches\jinja_v9.4.146.24.patch"
    cd ..\..
}

Write-Output "=====[ Make dynamic_crt ]====="
node "$PSScriptRoot\node-script\rep.js" "build\config\win\BUILD.gn"

Write-Output "=====[ add ArrayBuffer_New_Without_Stl ]====="
node "$PSScriptRoot\node-script\add_arraybuffer_new_without_stl.js" "."

node "$PSScriptRoot\node-script\patchs.js" "." $VERSION

Write-Output "=====[ Building V8 ]====="
if ($VERSION -eq "10.6.194" -or $VERSION -eq "11.8.172") {
    $args = 'target_os="win" target_cpu="x64" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false is_component_build=true'
} else {
    $args = 'target_os="win" target_cpu="x64" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false'
}
& gn gen out.gn\x64.release "--args=$args"
& ninja -C "out.gn\x64.release" -t clean
& ninja -v -C "out.gn\x64.release" v8

mkdir -Force output\v8\Lib\Win64DLL
Copy-Item -Path "out.gn\x64.release\v8.dll.lib" -Destination "output\v8\Lib\Win64DLL\" -Force
Copy-Item -Path "out.gn\x64.release\v8_libplatform.dll.lib" -Destination "output\v8\Lib\Win64DLL\" -Force
Copy-Item -Path "out.gn\x64.release\v8.dll" -Destination "output\v8\Lib\Win64DLL\" -Force
Copy-Item -Path "out.gn\x64.release\v8_libbase.dll" -Destination "output\v8\Lib\Win64DLL\" -Force
Copy-Item -Path "out.gn\x64.release\v8_libplatform.dll" -Destination "output\v8\Lib\Win64DLL\" -Force
Copy-Item -Path "out.gn\x64.release\zlib.dll" -Destination "output\v8\Lib\Win64DLL\" -Force
Copy-Item -Path "out.gn\x64.release\v8.dll.pdb" -Destination "output\v8\Lib\Win64DLL\" -Force
Copy-Item -Path "out.gn\x64.release\v8_libbase.dll.pdb" -Destination "output\v8\Lib\Win64DLL\" -Force
Copy-Item -Path "out.gn\x64.release\v8_libplatform.dll.pdb" -Destination "output\v8\Lib\Win64DLL\" -Force
Copy-Item -Path "out.gn\x64.release\zlib.dll.pdb" -Destination "output\v8\Lib\Win64DLL\" -Force
