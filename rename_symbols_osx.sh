#!/bin/bash

ARCH=$1
OUTPUT=$2

echo "ARCH=$1 OUTPUT=$2"

llvm-objcopy \
  --redefine-sym=__Znwm=___puerts_wrap__Znwm \
  --redefine-sym=__ZdlPv=___puerts_wrap__ZdlPv \
  --redefine-sym=__Znam=___puerts_wrap__Znam \
  --redefine-sym=__ZdaPv=___puerts_wrap__ZdaPv \
  --redefine-sym=__ZnwmRKSt9nothrow_t=___puerts_wrap__ZnwmRKSt9nothrow_t \
  --redefine-sym=__ZnamRKSt9nothrow_t=___puerts_wrap__ZnamRKSt9nothrow_t \
  --redefine-sym=__ZdaPvRKSt9nothrow_t=___puerts_wrap__ZdaPvRKSt9nothrow_t \
  --redefine-sym=__ZdaPvSt11align_val_t=___puerts_wrap__ZdaPvSt11align_val_t \
  --redefine-sym=__ZdaPvSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=__ZdaPvm=___puerts_wrap__ZdaPvm \
  --redefine-sym=__ZdaPvmSt11align_val_t=___puerts_wrap__ZdaPvmSt11align_val_t \
  --redefine-sym=__ZdlPvRKSt9nothrow_t=___puerts_wrap__ZdlPvRKSt9nothrow_t \
  --redefine-sym=__ZdlPvSt11align_val_t=___puerts_wrap__ZdlPvSt11align_val_t \
  --redefine-sym=__ZdlPvSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=__ZdlPvm=___puerts_wrap__ZdlPvm \
  --redefine-sym=__ZdlPvmSt11align_val_t=___puerts_wrap__ZdlPvmSt11align_val_t \
  --redefine-sym=__ZnamSt11align_val_t=___puerts_wrap__ZnamSt11align_val_t \
  --redefine-sym=__ZnamSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=__ZnwmSt11align_val_t=___puerts_wrap__ZnwmSt11align_val_t \
  --redefine-sym=__ZnwmSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t \
  out.gn/$ARCH.release/obj/libwee8.a 

ninja -v -C out.gn/$ARCH.release d8

llvm-ar rcs libv8_custom_libcxx.a out.gn/$ARCH.release/obj/buildtools/third_party/libc++/libc++/*.o

llvm-objcopy \
  --redefine-sym=__Znwm=___puerts_wrap__Znwm \
  --redefine-sym=__ZdlPv=___puerts_wrap__ZdlPv \
  --redefine-sym=__Znam=___puerts_wrap__Znam \
  --redefine-sym=__ZdaPv=___puerts_wrap__ZdaPv \
  --redefine-sym=__ZnwmRKSt9nothrow_t=___puerts_wrap__ZnwmRKSt9nothrow_t \
  --redefine-sym=__ZnamRKSt9nothrow_t=___puerts_wrap__ZnamRKSt9nothrow_t \
  --redefine-sym=__ZdaPvRKSt9nothrow_t=___puerts_wrap__ZdaPvRKSt9nothrow_t \
  --redefine-sym=__ZdaPvSt11align_val_t=___puerts_wrap__ZdaPvSt11align_val_t \
  --redefine-sym=__ZdaPvSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=__ZdaPvm=___puerts_wrap__ZdaPvm \
  --redefine-sym=__ZdaPvmSt11align_val_t=___puerts_wrap__ZdaPvmSt11align_val_t \
  --redefine-sym=__ZdlPvRKSt9nothrow_t=___puerts_wrap__ZdlPvRKSt9nothrow_t \
  --redefine-sym=__ZdlPvSt11align_val_t=___puerts_wrap__ZdlPvSt11align_val_t \
  --redefine-sym=__ZdlPvSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=__ZdlPvm=___puerts_wrap__ZdlPvm \
  --redefine-sym=__ZdlPvmSt11align_val_t=___puerts_wrap__ZdlPvmSt11align_val_t \
  --redefine-sym=__ZnamSt11align_val_t=___puerts_wrap__ZnamSt11align_val_t \
  --redefine-sym=__ZnamSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t \
  --redefine-sym=__ZnwmSt11align_val_t=___puerts_wrap__ZnwmSt11align_val_t \
  --redefine-sym=__ZnwmSt11align_val_tRKSt9nothrow_t=___puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t \
  libv8_custom_libcxx.a 
  
llvm-objcopy \
  --redefine-sym=__ZNKSt16nested_exception14rethrow_nestedEv=___ZNKSt16nested_exception14rethrow_nestedEv \
  --redefine-sym=__ZNSt13exception_ptrC1ERKS_=___ZNSt13exception_ptrC1ERKS_ \
  --redefine-sym=__ZNSt13exception_ptrC2ERKS_=___ZNSt13exception_ptrC2ERKS_ \
  --redefine-sym=__ZNSt13exception_ptrD1Ev=___ZNSt13exception_ptrD1Ev \
  --redefine-sym=__ZNSt13exception_ptrD2Ev=___ZNSt13exception_ptrD2Ev \
  --redefine-sym=__ZNSt13exception_ptraSERKS_=___ZNSt13exception_ptraSERKS_ \
  --redefine-sym=__ZNSt16nested_exceptionC1Ev=___ZNSt16nested_exceptionC1Ev \
  --redefine-sym=__ZNSt16nested_exceptionC2Ev=___ZNSt16nested_exceptionC2Ev \
  --redefine-sym=__ZNSt16nested_exceptionD0Ev=___ZNSt16nested_exceptionD0Ev \
  --redefine-sym=__ZNSt16nested_exceptionD1Ev=___ZNSt16nested_exceptionD1Ev \
  --redefine-sym=__ZNSt16nested_exceptionD2Ev=___ZNSt16nested_exceptionD2Ev \
  --redefine-sym=__ZSt17current_exceptionv=___ZSt17current_exceptionv \
  --redefine-sym=__ZSt17rethrow_exceptionSt13exception_ptr=___ZSt17rethrow_exceptionSt13exception_ptr \
  --redefine-sym=__ZSt18uncaught_exceptionv=___ZSt18uncaught_exceptionv \
  --redefine-sym=__ZSt19uncaught_exceptionsv=___ZSt19uncaught_exceptionsv \
  libv8_custom_libcxx.a 

mkdir v8_custom_libcxx
cd v8_custom_libcxx
llvm-ar x ../libv8_custom_libcxx.a
cd -
llvm-ar rcs out.gn/$ARCH.release/obj/libwee8.a v8_custom_libcxx/*.o
