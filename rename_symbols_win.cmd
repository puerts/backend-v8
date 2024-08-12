@echo off
setlocal

set ARCH=%~1
set OUTPUT=%~2

echo "%ARCH% out.gn/%ARCH%.release/obj/libwee8.a"

llvm-objcopy ^
  --redefine-sym="??2@YAPEAX_K@Z=__puerts_wrap__Znwm" ^
  --redefine-sym="??3@YAXPEAX@Z=__puerts_wrap__ZdlPv" ^
  --redefine-sym="??_U@YAPEAX_K@Z=__puerts_wrap__Znam" ^
  --redefine-sym="??_V@YAXPEAX@Z=__puerts_wrap__ZdaPv" ^
  --redefine-sym="??2@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnwmRKSt9nothrow_t" ^
  --redefine-sym="??_U@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnamRKSt9nothrow_t" ^
  --redefine-sym="??_V@YAXPEAXAEBUnothrow_t@std@@@Z=__puerts_wrap__ZdaPvRKSt9nothrow_t" ^
  --redefine-sym="??_V@YAXPEAXW4align_val_t@std@@@Z=__puerts_wrap__ZdaPvSt11align_val_t" ^
  --redefine-sym="??_V@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t" ^
  --redefine-sym="??_V@YAXPEAX_K@Z=__puerts_wrap__ZdaPvm" ^
  --redefine-sym="??_V@YAXPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZdaPvmSt11align_val_t" ^
  --redefine-sym="??3@YAXPEAXAEBUnothrow_t@std@@@Z=__puerts_wrap__ZdlPvRKSt9nothrow_t" ^
  --redefine-sym="??3@YAXPEAXW4align_val_t@std@@@Z=__puerts_wrap__ZdlPvSt11align_val_t" ^
  --redefine-sym="??3@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t" ^
  --redefine-sym="??3@YAXPEAX_K@Z=__puerts_wrap__ZdlPvm" ^
  --redefine-sym="??3@YAXPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZdlPvmSt11align_val_t" ^
  --redefine-sym="??_U@YAPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZnamSt11align_val_t" ^
  --redefine-sym="??_U@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t" ^
  --redefine-sym="??2@YAPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZnwmSt11align_val_t" ^
  --redefine-sym="??2@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t" ^
  out.gn\%ARCH%.release\obj\wee8.lib

call ninja -v -C out.gn\%ARCH%.release d8

echo "gen v8_custom_libcxx.lib"
lib.exe /OUT:v8_custom_libcxx.lib out.gn\%ARCH%.release\obj\buildtools\third_party\libc++\libc++\*.obj
dir

llvm-objcopy ^
  --redefine-sym="??2@YAPEAX_K@Z=__puerts_wrap__Znwm" ^
  --redefine-sym="??3@YAXPEAX@Z=__puerts_wrap__ZdlPv" ^
  --redefine-sym="??_U@YAPEAX_K@Z=__puerts_wrap__Znam" ^
  --redefine-sym="??_V@YAXPEAX@Z=__puerts_wrap__ZdaPv" ^
  --redefine-sym="??2@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnwmRKSt9nothrow_t" ^
  --redefine-sym="??_U@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnamRKSt9nothrow_t" ^
  --redefine-sym="??_V@YAXPEAXAEBUnothrow_t@std@@@Z=__puerts_wrap__ZdaPvRKSt9nothrow_t" ^
  --redefine-sym="??_V@YAXPEAXW4align_val_t@std@@@Z=__puerts_wrap__ZdaPvSt11align_val_t" ^
  --redefine-sym="??_V@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t" ^
  --redefine-sym="??_V@YAXPEAX_K@Z=__puerts_wrap__ZdaPvm" ^
  --redefine-sym="??_V@YAXPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZdaPvmSt11align_val_t" ^
  --redefine-sym="??3@YAXPEAXAEBUnothrow_t@std@@@Z=__puerts_wrap__ZdlPvRKSt9nothrow_t" ^
  --redefine-sym="??3@YAXPEAXW4align_val_t@std@@@Z=__puerts_wrap__ZdlPvSt11align_val_t" ^
  --redefine-sym="??3@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t" ^
  --redefine-sym="??3@YAXPEAX_K@Z=__puerts_wrap__ZdlPvm" ^
  --redefine-sym="??3@YAXPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZdlPvmSt11align_val_t" ^
  --redefine-sym="??_U@YAPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZnamSt11align_val_t" ^
  --redefine-sym="??_U@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t" ^
  --redefine-sym="??2@YAPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZnwmSt11align_val_t" ^
  --redefine-sym="??2@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t" ^
  v8_custom_libcxx.lib

llvm-objcopy ^
  --redefine-sym="??0exception_ptr@std@@QEAA@2801T@Z=??0exception_ptr___@std@@QEAA@2801T@Z" ^
  --redefine-sym="??0exception_ptr@std@@QEAA@AEBV01@@Z=??0exception_ptr___@std@@QEAA@AEBV01@@Z" ^
  --redefine-sym="??0exception_ptr@std@@QEAA@XZ=??0exception_ptr___@std@@QEAA@XZ" ^
  --redefine-sym="??0nested_exception@std@@QEAA@XZ=??0nested_exception___@std@@QEAA@XZ" ^
  --redefine-sym="??1exception_ptr@std@@QEAA@XZ=??1exception_ptr___@std@@QEAA@XZ" ^
  --redefine-sym="??1nested_exception@std@@UEAA@XZ=??1nested_exception___@std@@UEAA@XZ" ^
  --redefine-sym="??4exception_ptr@std@@QEAAAEAV01@2807T@Z=??4exception_ptr___@std@@QEAAAEAV01@2807T@Z" ^
  --redefine-sym="??4exception_ptr@std@@QEAAAEAV01@AEBV01@@Z=??4exception_ptr___@std@@QEAAAEAV01@AEBV01@@Z" ^
  --redefine-sym="??8std@@YA_NAEBVexception_ptr@0@0@Z=??8std@@YA_NAEBVexception_ptr___@0@0@Z" ^
  --redefine-sym="??Bexception_ptr@std@@QEBA_NXZ=??Bexception_ptr___@std@@QEBA_NXZ" ^
  --redefine-sym="??_Gnested_exception@std@@UEAAPEAXI@Z=??_Gnested_exception___@std@@UEAAPEAXI@Z" ^
  --redefine-sym="?__copy_exception_ptr@std@@YA?AVexception_ptr@1@PEAXPEBX@Z=?__copy_exception_ptr___@std@@YA?AVexception_ptr@1@PEAXPEBX@Z" ^
  --redefine-sym="?current_exception@std@@YA?AVexception_ptr@1@XZ=?current_exception___@std@@YA?AVexception_ptr@1@XZ" ^
  --redefine-sym="?get_terminate@std@@YAP6AXXZXZ=?get_terminate___@std@@YAP6AXXZXZ" ^
  --redefine-sym="?get_unexpected@std@@YAP6AXXZXZ=?get_unexpected___@std@@YAP6AXXZXZ" ^
  --redefine-sym="?rethrow_exception@std@@YAXVexception_ptr@1@@Z=?rethrow_exception___@std@@YAXVexception_ptr@1@@Z" ^
  --redefine-sym="?rethrow_nested@nested_exception@std@@QEBAXXZ=?rethrow_nested___@nested_exception@std@@QEBAXXZ" ^
  --redefine-sym="?set_terminate@std@@YAP6AXXZP6AXXZ@Z=?set_terminate___@std@@YAP6AXXZP6AXXZ@Z" ^
  --redefine-sym="?set_unexpected@std@@YAP6AXXZP6AXXZ@Z=?set_unexpected___@std@@YAP6AXXZP6AXXZ@Z" ^
  --redefine-sym="?swap@std@@YAXAEAVexception_ptr@1@0@Z=?swap@std@@YAXAEAVexception_ptr___@1@0@Z" ^
  --redefine-sym="?terminate@std@@YAXXZ=?terminate___@std@@YAXXZ" ^
  --redefine-sym="?uncaught_exception@std@@YA_NXZ=?uncaught_exception___@std@@YA_NXZ" ^
  --redefine-sym="?uncaught_exceptions@std@@YAHXZ=?uncaught_exceptions___@std@@YAHXZ" ^
  --redefine-sym="?unexpected@std@@YAXXZ=?unexpected___@std@@YAXXZ" ^
  v8_custom_libcxx.lib

lib.exe /OUT:wee8.lib out.gn\%ARCH%.release\obj\wee8.lib v8_custom_libcxx.lib
copy /Y wee8.lib out.gn\%ARCH%.release\obj\wee8.lib

endlocal
