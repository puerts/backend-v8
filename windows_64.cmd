set VERSION=%1
set NEW_WRAP=%1

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

if "%NEW_WRAP%"=="true" (
    echo =====[ wrap new delete ]=====
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\wrap_new_delete_v%VERSION%.patch
)

echo =====[ add ArrayBuffer_New_Without_Stl ]=====
node %~dp0\node-script\add_arraybuffer_new_without_stl.js .

node %~dp0\node-script\patchs.js . %VERSION%

echo =====[ Building V8 ]=====
if "%VERSION%"=="11.8.172" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false v8_static_library=true is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false v8_enable_sandbox=false v8_enable_maglev=false"
)

if "%VERSION%"=="10.6.194" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false v8_static_library=true is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false v8_enable_sandbox=false"
)

if "%VERSION%"=="9.4.146.24" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false v8_static_library=true is_clang=false strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false"
)
call ninja -C out.gn\x64.release -t clean
call ninja -v -C out.gn\x64.release wee8

md output\v8\Lib\Win64
if "%NEW_WRAP%"=="true" (
  llvm-objcopy --redefine-sym="??2@YAPEAX_K@Z=__puerts_wrap__Znwm" --redefine-sym="??3@YAXPEAX_K@Z=__puerts_wrap__ZdlPv" --redefine-sym="??_U@YAPEAX_K@Z=__puerts_wrap__Znam" --redefine-sym="??_V@YAXPEAX@Z=__puerts_wrap__ZdaPv" --redefine-sym="??2@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnwmRKSt9nothrow_t" --redefine-sym="??_U@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnamRKSt9nothrow_t" out.gn\x64.release\obj\wee8.lib
)
copy /Y out.gn\x64.release\obj\wee8.lib output\v8\Lib\Win64\

echo =====[ Copy V8 header ]=====
xcopy include output\v8\Inc\  /s/h/e/k/f/c

md output\v8\Bin\Win64
copy /Y out.gn\x64.release\v8cc.exe output\v8\Bin\Win64\
copy /Y out.gn\x64.release\mksnapshot.exe output\v8\Bin\Win64\