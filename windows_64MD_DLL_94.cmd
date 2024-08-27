set VERSION=%1
set NEW_WRAP=%2

cd /d %USERPROFILE%
echo =====[ Getting Depot Tools ]=====
powershell -command "Invoke-WebRequest https://storage.googleapis.com/chrome-infra/depot_tools.zip -O depot_tools.zip"
7z x depot_tools.zip -o*
set PATH=%CD%\depot_tools;%PATH%
set GYP_MSVS_VERSION=2019
set DEPOT_TOOLS_WIN_TOOLCHAIN=0
call gclient

cd depot_tools
call git reset --hard 8d16d4a
cd ..
set DEPOT_TOOLS_UPDATE=0


mkdir v8
cd v8

echo =====[ Fetching V8 ]=====
call fetch v8
cd v8
call git checkout refs/tags/%VERSION%
@REM cd test\test262\data
call git config --system core.longpaths true
@REM call git restore *
@REM cd ..\..\..\
call gclient sync

@REM echo =====[ Patching V8 ]=====
@REM node %GITHUB_WORKSPACE%\CRLF2LF.js %GITHUB_WORKSPACE%\patches\builtins-puerts.patches
@REM call git apply --cached --reject %GITHUB_WORKSPACE%\patches\builtins-puerts.patches
@REM call git checkout -- .

if "%VERSION%"=="10.6.194" (
    echo =====[ patch 10.6.194 ]=====
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\win_msvc_v10.6.194.patch
)

if "%VERSION%"=="11.8.172" (
    echo =====[ patch 10.6.194 ]=====
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\remove_uchar_include_v11.8.172.patch
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\win_dll_v11.8.172.patch"
)

if "%VERSION%"=="9.4.146.24" (
    echo =====[ patch jinja for python3.10+ ]=====
    cd third_party\jinja2
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\jinja_v9.4.146.24.patch
    cd ..\..
)

set "CXX_SETTING=is_clang=false use_custom_libcxx=false"

if "%NEW_WRAP%"=="with_new_wrap" (
    echo =====[ wrap new delete ]=====
    set "CXX_SETTING=is_clang=true use_custom_libcxx=true libcxx_is_shared=false"
)

if "%VERSION%"=="9.4.146.24" (
    set "CXX_SETTING=is_clang=false"
)

echo =====[ Make dynamic_crt ]=====
node %~dp0\node-script\rep.js  build\config\win\BUILD.gn

echo =====[ commenting out Zc_inline  ]=====
node -e "const fs = require('fs'); fs.writeFileSync('./build/config/compiler/BUILD.gn', fs.readFileSync('./build/config/compiler/BUILD.gn', 'utf-8').replace('\"/Zc:inline\"', '#\"/Zc:inline\"'));"

echo =====[ add ArrayBuffer_New_Without_Stl ]=====
node %~dp0\node-script\add_arraybuffer_new_without_stl.js . %VERSION% %NEW_WRAP%

node %~dp0\node-script\patchs.js . %VERSION% %NEW_WRAP%

echo =====[ Building V8 ]=====
if "%VERSION%"=="11.8.172" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false %CXX_SETTING% strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false is_component_build=true v8_enable_sandbox=false v8_enable_maglev=false v8_enable_webassembly=false"
)

if "%VERSION%"=="10.6.194" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false %CXX_SETTING% strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false is_component_build=true v8_enable_sandbox=false"
)

if "%VERSION%"=="9.4.146.24" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false %CXX_SETTING% strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false is_component_build=true"
)

call ninja -C out.gn\x64.release -t clean
if "%NEW_WRAP%"=="with_new_wrap" (
  copy /Y %~dp0\node-script\win_compile_and_objcopy.js tools
  node -e "const fs = require('fs'); fs.writeFileSync('out.gn/x64.release/toolchain.ninja', fs.readFileSync('out.gn/x64.release/toolchain.ninja', 'utf-8').replace(/(rule cxx[\s\S]*?command\s*=\s*)(.*clang-cl\.exe.*)/g, '$1node ..\\..\\tools\\win_compile_and_objcopy.js $2'));
)
call ninja -v -C out.gn\x64.release v8

md output\v8\Lib\Win64DLL
copy /Y out.gn\x64.release\v8.dll.lib output\v8\Lib\Win64DLL\
copy /Y out.gn\x64.release\v8_libplatform.dll.lib output\v8\Lib\Win64DLL\
copy /Y out.gn\x64.release\v8.dll output\v8\Lib\Win64DLL\
copy /Y out.gn\x64.release\v8_libbase.dll output\v8\Lib\Win64DLL\
copy /Y out.gn\x64.release\v8_libplatform.dll output\v8\Lib\Win64DLL\
copy /Y out.gn\x64.release\v8.dll.pdb output\v8\Lib\Win64DLL\
copy /Y out.gn\x64.release\v8_libbase.dll.pdb output\v8\Lib\Win64DLL\
copy /Y out.gn\x64.release\v8_libplatform.dll.pdb output\v8\Lib\Win64DLL\

if "%VERSION%"=="11.8.172" (
  copy /Y out.gn\x64.release\third_party_zlib.dll output\v8\Lib\Win64DLL\
  copy /Y out.gn\x64.release\third_party_zlib.dll.pdb output\v8\Lib\Win64DLL\
  copy /Y out.gn\x64.release\third_party_abseil-cpp_absl.dll output\v8\Lib\Win64DLL\
  copy /Y out.gn\x64.release\third_party_abseil-cpp_absl.dll.pdb output\v8\Lib\Win64DLL\
) else (
  copy /Y out.gn\x64.release\zlib.dll output\v8\Lib\Win64DLL\
  copy /Y out.gn\x64.release\zlib.dll.pdb output\v8\Lib\Win64DLL\
)
