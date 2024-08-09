@echo off
setlocal

set ARCH=%~1
set OUTPUT=%~2

echo "%OBJCOPY% out.gn/%ARCH%.release/obj/libwee8.a"

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

pushd out.gn\%ARCH%.release\obj\buildtools\third_party\libc++\libc++

lib /OUT:v8_custom_libcxx.lib *.obj

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
  --redefine-sym="??0exception_ptr@std@@QEAA@AEBV01@@Z=??0exception_ptr___@std@@QEAA@AEBV01@@Z" ^
  --redefine-sym="??1exception_ptr@std@@QEAA@XZ=??1exception_ptr__@std@@QEAA@XZ" ^
  --redefine-sym="?rethrow_exception@std@@YAXVexception_ptr@1@@Z=?rethrow_exception__@std@@YAXVexception_ptr@1@@Z" ^
  v8_custom_libcxx.lib
  
popd

copy /Y out.gn\%ARCH%.release\obj\buildtools\third_party\libc++\libc++\v8_custom_libcxx.lib %OUTPUT%

endlocal
