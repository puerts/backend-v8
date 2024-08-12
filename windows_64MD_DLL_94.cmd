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
    node %~dp0\node-script\do-gitpatch.js -p %GITHUB_WORKSPACE%\patches\wrap_new_delete_v%VERSION%.patch
    set "CXX_SETTING=is_clang=true use_custom_libcxx=true"
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
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false %CXX_SETTING% strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false is_component_build=true v8_enable_sandbox=false v8_enable_maglev=false"
)

if "%VERSION%"=="10.6.194" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false %CXX_SETTING% strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false is_component_build=true v8_enable_sandbox=false"
)

if "%VERSION%"=="9.4.146.24" (
    call gn gen out.gn\x64.release -args="target_os=""win"" target_cpu=""x64"" v8_use_external_startup_data=false v8_enable_i18n_support=false is_debug=false %CXX_SETTING% strip_debug_info=true symbol_level=0 v8_enable_pointer_compression=false is_component_build=true"
)

call ninja -C out.gn\x64.release -t clean
if "%NEW_WRAP%"=="with_new_wrap" (
  node -e "const fs = require('fs'); fs.writeFileSync('out.gn/x64.release/toolchain.ninja', fs.readFileSync('out.gn/x64.release/toolchain.ninja', 'utf-8').replace(/(rule cxx\n\s+command = [^\n]+)/g, '$1 && llvm-objcopy --redefine-sym=""??2@YAPEAX_K@Z=__puerts_wrap__Znwm"" --redefine-sym=""??3@YAXPEAX@Z=__puerts_wrap__ZdlPv"" --redefine-sym=""??_U@YAPEAX_K@Z=__puerts_wrap__Znam"" --redefine-sym=""??_V@YAXPEAX@Z=__puerts_wrap__ZdaPv"" --redefine-sym=""??2@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnwmRKSt9nothrow_t"" --redefine-sym=""??_U@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnamRKSt9nothrow_t"" --redefine-sym=""??_V@YAXPEAXAEBUnothrow_t@std@@@Z=__puerts_wrap__ZdaPvRKSt9nothrow_t"" --redefine-sym=""??_V@YAXPEAXW4align_val_t@std@@@Z=__puerts_wrap__ZdaPvSt11align_val_t"" --redefine-sym=""??_V@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t"" --redefine-sym=""??_V@YAXPEAX_K@Z=__puerts_wrap__ZdaPvm"" --redefine-sym=""??_V@YAXPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZdaPvmSt11align_val_t"" --redefine-sym=""??3@YAXPEAXAEBUnothrow_t@std@@@Z=__puerts_wrap__ZdlPvRKSt9nothrow_t"" --redefine-sym=""??3@YAXPEAXW4align_val_t@std@@@Z=__puerts_wrap__ZdlPvSt11align_val_t"" --redefine-sym=""??3@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t"" --redefine-sym=""??3@YAXPEAX_K@Z=__puerts_wrap__ZdlPvm"" --redefine-sym=""??3@YAXPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZdlPvmSt11align_val_t"" --redefine-sym=""??_U@YAPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZnamSt11align_val_t"" --redefine-sym=""??_U@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t"" --redefine-sym=""??2@YAPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZnwmSt11align_val_t"" --redefine-sym=""??2@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t"" --redefine-sym=""??0exception_ptr@std@@QEAA@2801T@Z=??0exception_ptr___@std@@QEAA@2801T@Z"" --redefine-sym=""??0exception_ptr@std@@QEAA@AEBV01@@Z=??0exception_ptr___@std@@QEAA@AEBV01@@Z"" --redefine-sym=""??0exception_ptr@std@@QEAA@XZ=??0exception_ptr___@std@@QEAA@XZ"" --redefine-sym=""??0nested_exception@std@@QEAA@XZ=??0nested_exception___@std@@QEAA@XZ"" --redefine-sym=""??1exception_ptr@std@@QEAA@XZ=??1exception_ptr___@std@@QEAA@XZ"" --redefine-sym=""??1nested_exception@std@@UEAA@XZ=??1nested_exception___@std@@UEAA@XZ"" --redefine-sym=""??4exception_ptr@std@@QEAAAEAV01@2807T@Z=??4exception_ptr___@std@@QEAAAEAV01@2807T@Z"" --redefine-sym=""??4exception_ptr@std@@QEAAAEAV01@AEBV01@@Z=??4exception_ptr___@std@@QEAAAEAV01@AEBV01@@Z"" --redefine-sym=""??8std@@YA_NAEBVexception_ptr@0@0@Z=??8std@@YA_NAEBVexception_ptr___@0@0@Z"" --redefine-sym=""??Bexception_ptr@std@@QEBA_NXZ=??Bexception_ptr___@std@@QEBA_NXZ"" --redefine-sym=""??_Gnested_exception@std@@UEAAPEAXI@Z=??_Gnested_exception___@std@@UEAAPEAXI@Z"" --redefine-sym=""?__copy_exception_ptr@std@@YA?AVexception_ptr@1@PEAXPEBX@Z=?__copy_exception_ptr___@std@@YA?AVexception_ptr@1@PEAXPEBX@Z"" --redefine-sym=""?current_exception@std@@YA?AVexception_ptr@1@XZ=?current_exception___@std@@YA?AVexception_ptr@1@XZ"" --redefine-sym=""?get_terminate@std@@YAP6AXXZXZ=?get_terminate___@std@@YAP6AXXZXZ"" --redefine-sym=""?get_unexpected@std@@YAP6AXXZXZ=?get_unexpected___@std@@YAP6AXXZXZ"" --redefine-sym=""?rethrow_exception@std@@YAXVexception_ptr@1@@Z=?rethrow_exception___@std@@YAXVexception_ptr@1@@Z"" --redefine-sym=""?rethrow_nested@nested_exception@std@@QEBAXXZ=?rethrow_nested___@nested_exception@std@@QEBAXXZ"" --redefine-sym=""?set_terminate@std@@YAP6AXXZP6AXXZ@Z=?set_terminate___@std@@YAP6AXXZP6AXXZ@Z"" --redefine-sym=""?set_unexpected@std@@YAP6AXXZP6AXXZ@Z=?set_unexpected___@std@@YAP6AXXZP6AXXZ@Z"" --redefine-sym=""?swap@std@@YAXAEAVexception_ptr@1@0@Z=?swap@std@@YAXAEAVexception_ptr___@1@0@Z"" --redefine-sym=""?terminate@std@@YAXXZ=?terminate___@std@@YAXXZ"" --redefine-sym=""?uncaught_exception@std@@YA_NXZ=?uncaught_exception___@std@@YA_NXZ"" --redefine-sym=""?uncaught_exceptions@std@@YAHXZ=?uncaught_exceptions___@std@@YAHXZ"" --redefine-sym=""?unexpected@std@@YAXXZ=?unexpected___@std@@YAXXZ"" ${out}'));
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
) else (
  copy /Y out.gn\x64.release\zlib.dll output\v8\Lib\Win64DLL\
  copy /Y out.gn\x64.release\zlib.dll.pdb output\v8\Lib\Win64DLL\
)