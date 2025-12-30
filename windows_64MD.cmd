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

if "%VERSION%"=="9.4.146.24" (
    cd depot_tools
    call git reset --hard 8d16d4a
    cd ..
)
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
call gclient sync -D

if "%VERSION%"=="10.6.194" (
    echo =====[ patch 10.6.194 ]=====
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\win_msvc_v10.6.194.patch
)

if "%VERSION%"=="11.8.172" (
    echo =====[ patch 10.6.194 ]=====
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\remove_uchar_include_v11.8.172.patch
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\win_dll_v11.8.172.patch"
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\enable_wee8_v11.8.172.patch
)

if "%VERSION%"=="12.9.202.27" (
    echo =====[ patch 12.9.202.27 ]=====
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\enable_wee8_v12.9.202.27.patch
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
    set "CXX_SETTING=is_clang=true use_custom_libcxx=true"
)

if "%VERSION%"=="9.4.146.24" (
    set "CXX_SETTING=is_clang=false"
)

@REM echo =====[ Patching V8 ]=====
@REM node %GITHUB_WORKSPACE%\CRLF2LF.js %GITHUB_WORKSPACE%\patches\builtins-puerts.patches
@REM call git apply --cached --reject %GITHUB_WORKSPACE%\patches\builtins-puerts.patches
@REM call git checkout -- .

echo =====[ Make dynamic_crt ]=====
node %~dp0\node-script\rep.js  build\config\win\BUILD.gn

echo =====[ add ArrayBuffer_New_Without_Stl ]=====
node %~dp0\node-script\add_arraybuffer_new_without_stl.js . %VERSION% %NEW_WRAP%

node %~dp0\node-script\patchs.js . %VERSION% %NEW_WRAP%

echo =====[ Building V8 ]=====
if "%VERSION%"=="9.4.146.24" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false v8_static_library=true %CXX_SETTING% strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false"
) else if "%VERSION%"=="10.6.194" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false v8_static_library=true %CXX_SETTING% strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false v8_enable_sandbox=false"
) else (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false v8_static_library=true %CXX_SETTING% strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false v8_enable_sandbox=false v8_enable_maglev=false v8_enable_webassembly=false"
)
call ninja -C out.gn\x64.release -t clean
call ninja -v -C out.gn\x64.release wee8

md output\v8\Lib\Win64MD
if "%NEW_WRAP%"=="with_new_wrap" (
  call %~dp0\rename_symbols_win.cmd x64 output\v8\Lib\Win64MD\
)
copy /Y out.gn\x64.release\obj\wee8.lib output\v8\Lib\Win64MD\
md output\v8\Inc\Blob\Win64MD
