#include <__config>
#include <stdlib.h>
#include <cstdlib>
#include <stdio.h>
#include <new>

extern "C" {

//_Znwm -> operator new(unsigned long)
//"??2@YAPEAX_K@Z"
void* __puerts_wrap__Znwm(unsigned long size) {
    void* ptr = ::malloc(size);
    if (!ptr) {
        fprintf(stderr, "Fatal process out of memory for new");
        abort();
    }
    return ptr;
}

//_ZdlPv -> operator delete(void*)
//"??3@YAXPEAX@Z"
void __puerts_wrap__ZdlPv(void* ptr) noexcept {
    ::free(ptr);
}

//_Znam -> operator new[](unsigned long)
//"??_U@YAPEAX_K@Z"
void* __puerts_wrap__Znam(unsigned long size) {
    void* ptr = ::malloc(size);
    if (!ptr) {
        fprintf(stderr, "Fatal process out of memory for new");
        abort();
    }
    return ptr;
}

//_ZdaPv -> operator delete[](void*)
//"??_V@YAXPEAX@Z"
void __puerts_wrap__ZdaPv(void* ptr) noexcept {
    ::free(ptr);
}

//_ZnwmRKSt9nothrow_t -> operator new(unsigned long, std::nothrow_t const&)
//"??2@YAPEAX_KAEBUnothrow_t@std@@@Z"
void* __puerts_wrap__ZnwmRKSt9nothrow_t(unsigned long size) {
    return ::malloc(size);
}

//_ZnamRKSt9nothrow_t -> operator new[](unsigned long, std::nothrow_t const&)
//"??_U@YAPEAX_KAEBUnothrow_t@std@@@Z"
void* __puerts_wrap__ZnamRKSt9nothrow_t(unsigned long size) {
    return ::malloc(size);
}

//_ZdaPvRKSt9nothrow_t -> operator delete[](void*, std::nothrow_t const&)
//"??_V@YAXPEAXAEBUnothrow_t@std@@@Z"
void __puerts_wrap__ZdaPvRKSt9nothrow_t(void* ptr, void*) {
    ::free(ptr);
}

//_ZdaPvSt11align_val_t -> operator delete[](void*, std::align_val_t)
//"??_V@YAXPEAXW4align_val_t@std@@@Z"
void __puerts_wrap__ZdaPvSt11align_val_t(void* ptr, size_t) {
    ::free(ptr);
}

//_ZdaPvSt11align_val_tRKSt9nothrow_t -> operator delete[](void*, std::align_val_t, std::nothrow_t const&)
//"??_V@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z"
void __puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t(void* ptr, size_t, void*) {
    ::free(ptr);
}

//_ZdaPvm -> operator delete[](void*, unsigned long)
//"??_V@YAXPEAX_K@Z"
void __puerts_wrap__ZdaPvm(void* ptr, unsigned long) {
    ::free(ptr);
}

//_ZdaPvmSt11align_val_t -> operator delete[](void*, unsigned long, std::align_val_t)
//"??_V@YAXPEAX_KW4align_val_t@std@@@Z"
void __puerts_wrap__ZdaPvmSt11align_val_t(void* ptr, unsigned long, size_t) {
    ::free(ptr);
}

//_ZdlPvRKSt9nothrow_t -> operator delete(void*, std::nothrow_t const&)
//"??3@YAXPEAXAEBUnothrow_t@std@@@Z"
void __puerts_wrap__ZdlPvRKSt9nothrow_t(void* ptr, void*) {
    ::free(ptr);
}

//_ZdlPvSt11align_val_t -> operator delete(void*, std::align_val_t)
//"??3@YAXPEAXW4align_val_t@std@@@Z"
void __puerts_wrap__ZdlPvSt11align_val_t(void* ptr, size_t) {
    ::free(ptr);
}

//_ZdlPvSt11align_val_tRKSt9nothrow_t -> operator delete(void*, std::align_val_t, std::nothrow_t const&)
//"??3@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z"
void __puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t(void* ptr, size_t, void*){
    ::free(ptr);
}

//_ZdlPvm -> operator delete(void*, unsigned long)
//"??3@YAXPEAX_K@Z"
void __puerts_wrap__ZdlPvm(void* ptr, unsigned long) {
    ::free(ptr);
}

//_ZdlPvmSt11align_val_t -> operator delete(void*, unsigned long, std::align_val_t)
//"??3@YAXPEAX_KW4align_val_t@std@@@Z"
void __puerts_wrap__ZdlPvmSt11align_val_t(void* ptr, unsigned long, size_t) {
    ::free(ptr);
}

#if __cplusplus >= 201703L && (!defined(V8_OS_ANDROID) || defined(_LIBCPP_HAS_ALIGNED_ALLOC)) && !defined(_LIBCPP_HAS_NO_ALIGNED_ALLOCATION) && !defined(_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION) && _LIBCPP_STD_VER >= 17

//_ZnamSt11align_val_t -> operator new[](unsigned long, std::align_val_t)
//"??_U@YAPEAX_KW4align_val_t@std@@@Z"
void* __puerts_wrap__ZnamSt11align_val_t(unsigned long size, size_t alignment) {
#if defined(_WIN32)
    return _aligned_malloc(size, alignment);
#elif defined(__APPLE__)
    #include <AvailabilityMacros.h>
    #if __MAC_OS_X_VERSION_MIN_REQUIRED >= 101500
        return std::aligned_alloc(alignment, size);
    #else
        void* ptr = nullptr;
        if (posix_memalign(&ptr, alignment, size) != 0) {
            fprintf(stderr, "Fatal process out of memory for new");
            abort();
        }
        return ptr;
    #endif
#else
    return std::aligned_alloc(alignment, size);
#endif
}

//_ZnamSt11align_val_tRKSt9nothrow_t -> operator new[](unsigned long, std::align_val_t, std::nothrow_t const&)
//"??_U@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z"
void* __puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t(unsigned long size, size_t alignment, void*) {
#if defined(_WIN32)
    return _aligned_malloc(size, alignment);
#elif defined(__APPLE__)
    #include <AvailabilityMacros.h>
    #if __MAC_OS_X_VERSION_MIN_REQUIRED >= 101500
        return std::aligned_alloc(alignment, size);
    #else
        void* ptr = nullptr;
        if (posix_memalign(&ptr, alignment, size) != 0) {
            return nullptr;
        }
        return ptr;
    #endif
#else
    return std::aligned_alloc(alignment, size);
#endif
}

//_ZnwmSt11align_val_t -> operator new(unsigned long, std::align_val_t)
//"??2@YAPEAX_KW4align_val_t@std@@@Z"
void* __puerts_wrap__ZnwmSt11align_val_t(unsigned long size, size_t alignment) {
#if defined(_WIN32)
    return _aligned_malloc(size, alignment);
#elif defined(__APPLE__)
    #include <AvailabilityMacros.h>
    #if __MAC_OS_X_VERSION_MIN_REQUIRED >= 101500
        return std::aligned_alloc(alignment, size);
    #else
        void* ptr = nullptr;
        if (posix_memalign(&ptr, alignment, size) != 0) {
            fprintf(stderr, "Fatal process out of memory for new");
            abort();
        }
        return ptr;
    #endif
#else
    return std::aligned_alloc(alignment, size);
#endif
}

//_ZnwmSt11align_val_tRKSt9nothrow_t -> operator new(unsigned long, std::align_val_t, std::nothrow_t const&)
//"??2@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z"
void* __puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t(unsigned long size, size_t alignment, void*) {
#if defined(_WIN32)
    return _aligned_malloc(size, alignment);
#elif defined(__APPLE__)
    #include <AvailabilityMacros.h>
    #if __MAC_OS_X_VERSION_MIN_REQUIRED >= 101500
        return std::aligned_alloc(alignment, size);
    #else
        void* ptr = nullptr;
        if (posix_memalign(&ptr, alignment, size) != 0) {
            return nullptr;
        }
        return ptr;
    #endif
#else
    return std::aligned_alloc(alignment, size);
#endif
}

#endif

}
