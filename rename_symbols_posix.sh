#!/bin/bash

ARCH=$2
OUTPUT=$3

if [ -n "$1" ] && [ "$1" != "" ]; then
    DIRECTORY="$1"
    LLVM_AR="$DIRECTORY/llvm-ar"
    LLVM_OBJCOPY="$DIRECTORY/llvm-objcopy"
else
    LLVM_AR="llvm-ar"
    LLVM_OBJCOPY="$DIRECTORY/llvm-objcopy"
fi

echo "$LLVM_OBJCOPY out.gn/$ARCH.release/obj/libwee8.a"

$LLVM_OBJCOPY \
  --redefine-sym=_Znwm=__puerts_wrap__Znwm \
  --redefine-sym=_ZdlPv=__puerts_wrap__ZdlPv \
  --redefine-sym=_Znam=__puerts_wrap__Znam \
  --redefine-sym=_ZdaPv=__puerts_wrap__ZdaPv \
  --redefine-sym=_ZnwmRKSt9nothrow_t=__puerts_wrap__ZnwmRKSt9nothrow_t \
  --redefine-sym=_ZnamRKSt9nothrow_t=__puerts_wrap__ZnamRKSt9nothrow_t \
  --redefine-sym=_ZdaPvRKSt9nothrow_t=__puerts_wrap__ZdaPvRKSt9nothrow_t \
  --redefine-sym=_ZdaPvSt11align_val_t=__puerts_wrap__ZdaPvSt11align_val_t \
  --redefine-sym=_ZdaPvSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=_ZdaPvm=__puerts_wrap__ZdaPvm \
  --redefine-sym=_ZdaPvmSt11align_val_t=__puerts_wrap__ZdaPvmSt11align_val_t \
  --redefine-sym=_ZdlPvRKSt9nothrow_t=__puerts_wrap__ZdlPvRKSt9nothrow_t \
  --redefine-sym=_ZdlPvSt11align_val_t=__puerts_wrap__ZdlPvSt11align_val_t \
  --redefine-sym=_ZdlPvSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=_ZdlPvm=__puerts_wrap__ZdlPvm \
  --redefine-sym=_ZdlPvmSt11align_val_t=__puerts_wrap__ZdlPvmSt11align_val_t \
  --redefine-sym=_ZnamSt11align_val_t=__puerts_wrap__ZnamSt11align_val_t \
  --redefine-sym=_ZnamSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=_ZnwmSt11align_val_t=__puerts_wrap__ZnwmSt11align_val_t \
  --redefine-sym=_ZnwmSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t \
  out.gn/$ARCH.release/obj/libwee8.a 

ninja -v -C out.gn/$ARCH.release d8

$LLVM_AR rcs libv8_custom_libcxx.a out.gn/$ARCH.release/obj/buildtools/third_party/libc++/libc++/*.o

$LLVM_OBJCOPY \
  --redefine-sym=_Znwm=__puerts_wrap__Znwm \
  --redefine-sym=_ZdlPv=__puerts_wrap__ZdlPv \
  --redefine-sym=_Znam=__puerts_wrap__Znam \
  --redefine-sym=_ZdaPv=__puerts_wrap__ZdaPv \
  --redefine-sym=_ZnwmRKSt9nothrow_t=__puerts_wrap__ZnwmRKSt9nothrow_t \
  --redefine-sym=_ZnamRKSt9nothrow_t=__puerts_wrap__ZnamRKSt9nothrow_t \
  --redefine-sym=_ZdaPvRKSt9nothrow_t=__puerts_wrap__ZdaPvRKSt9nothrow_t \
  --redefine-sym=_ZdaPvSt11align_val_t=__puerts_wrap__ZdaPvSt11align_val_t \
  --redefine-sym=_ZdaPvSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=_ZdaPvm=__puerts_wrap__ZdaPvm \
  --redefine-sym=_ZdaPvmSt11align_val_t=__puerts_wrap__ZdaPvmSt11align_val_t \
  --redefine-sym=_ZdlPvRKSt9nothrow_t=__puerts_wrap__ZdlPvRKSt9nothrow_t \
  --redefine-sym=_ZdlPvSt11align_val_t=__puerts_wrap__ZdlPvSt11align_val_t \
  --redefine-sym=_ZdlPvSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=_ZdlPvm=__puerts_wrap__ZdlPvm \
  --redefine-sym=_ZdlPvmSt11align_val_t=__puerts_wrap__ZdlPvmSt11align_val_t \
  --redefine-sym=_ZnamSt11align_val_t=__puerts_wrap__ZnamSt11align_val_t \
  --redefine-sym=_ZnamSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=_ZnwmSt11align_val_t=__puerts_wrap__ZnwmSt11align_val_t \
  --redefine-sym=_ZnwmSt11align_val_tRKSt9nothrow_t=__puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t \
  libv8_custom_libcxx.a 
  
cp libv8_custom_libcxx.a $OUTPUT
