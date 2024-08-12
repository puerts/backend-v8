#!/bin/bash

ARCH=$1
OUTPUT=$2

echo "ARCH=$1 OUTPUT=$2"

llvm-objcopy \
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

llvm-ar rcs libv8_custom_libcxx.a out.gn/$ARCH.release/obj/buildtools/third_party/libc++/libc++/*.o

llvm-objcopy \
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
  
llvm-objcopy \
  --redefine-sym=_ZNKSt16nested_exception14rethrow_nestedEv=___ZNKSt16nested_exception14rethrow_nestedEv \
  --redefine-sym=_ZNSt13exception_ptrC1ERKS_=___ZNSt13exception_ptrC1ERKS_ \
  --redefine-sym=_ZNSt13exception_ptrC2ERKS_=___ZNSt13exception_ptrC2ERKS_ \
  --redefine-sym=_ZNSt13exception_ptrD1Ev=___ZNSt13exception_ptrD1Ev \
  --redefine-sym=_ZNSt13exception_ptrD2Ev=___ZNSt13exception_ptrD2Ev \
  --redefine-sym=_ZNSt13exception_ptraSERKS_=___ZNSt13exception_ptraSERKS_ \
  --redefine-sym=_ZNSt16nested_exceptionC1Ev=___ZNSt16nested_exceptionC1Ev \
  --redefine-sym=_ZNSt16nested_exceptionC2Ev=___ZNSt16nested_exceptionC2Ev \
  --redefine-sym=_ZNSt16nested_exceptionD0Ev=___ZNSt16nested_exceptionD0Ev \
  --redefine-sym=_ZNSt16nested_exceptionD1Ev=___ZNSt16nested_exceptionD1Ev \
  --redefine-sym=_ZNSt16nested_exceptionD2Ev=___ZNSt16nested_exceptionD2Ev \
  --redefine-sym=_ZSt17current_exceptionv=___ZSt17current_exceptionv \
  --redefine-sym=_ZSt17rethrow_exceptionSt13exception_ptr=___ZSt17rethrow_exceptionSt13exception_ptr \
  --redefine-sym=_ZSt18uncaught_exceptionv=___ZSt18uncaught_exceptionv \
  --redefine-sym=_ZSt19uncaught_exceptionsv=___ZSt19uncaught_exceptionsv \
  libv8_custom_libcxx.a 
  
mkdir v8_custom_libcxx
cd v8_custom_libcxx
llvm-ar x ../libv8_custom_libcxx.a
cd -
llvm-ar rcs out.gn/$ARCH.release/obj/libwee8.a v8_custom_libcxx/*.o
