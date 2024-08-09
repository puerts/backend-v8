#!/bin/bash

OBJCOPY=$1
ARCH=$2

echo "$OBJCOPY out.gn/$ARCH.release/obj/libwee8.a"

$OBJCOPY \
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

