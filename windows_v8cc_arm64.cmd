set VERSION=%1

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
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\enable_wee8_v11.8.172.patch
)

if "%VERSION%"=="9.4.146.24" (
    echo =====[ patch jinja for python3.10+ ]=====
    cd third_party\jinja2
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\jinja_v9.4.146.24.patch
    cd ..\..
)

echo =====[ add ArrayBuffer_New_Without_Stl ]=====
node %~dp0\node-script\add_arraybuffer_new_without_stl.js . %VERSION% %NEW_WRAP%

node %~dp0\node-script\add_cross_v8cc.js . %VERSION% arm64

echo =====[ Building V8 ]=====
if "%VERSION%"=="11.8.172" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false v8_static_library=true is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false v8_enable_sandbox=false v8_enable_maglev=false v8_enable_webassembly=false"
)

if "%VERSION%"=="10.6.194" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false v8_static_library=true is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false v8_enable_sandbox=false v8_enable_webassembly=false "
)

if "%VERSION%"=="9.4.146.24" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false v8_static_library=true is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false"
)

call ninja -v -C out.gn\x64.release v8cc

md output\v8\Bin\Win\arm64
copy /Y out.gn\x64.release\v8cc.exe output\v8\Bin\Win\arm64\