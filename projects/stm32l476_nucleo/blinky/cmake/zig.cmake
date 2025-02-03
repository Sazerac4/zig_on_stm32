include_guard()

# Tutorial: https://kubasejdak.com/how-to-cross-compile-for-embedded-with-cmake-like-a-champ
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
message("Use zig as compiler")

# Flags
set(CPU_PARAMETERS "-mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mcpu=cortex_m4")
set(FLAGS "-fdata-sections -ffunction-sections ${CPU_PARAMETERS}")
set(CPP_FLAGS "${FLAGS} -fno-rtti -fno-exceptions -fno-threadsafe-statics")

if(CMAKE_HOST_WIN32)
    set(SCRIPT_SUFFIX ".cmd")
else()
    set(SCRIPT_SUFFIX "")
endif()

set(CMAKE_C_FLAGS ${FLAGS})
set(CMAKE_CXX_FLAGS ${CPP_FLAGS})
set(CMAKE_ASM_FLAGS ${FLAGS})


set(CMAKE_C_COMPILER "${CMAKE_CURRENT_LIST_DIR}/zig-cc${SCRIPT_SUFFIX}" -target ${TARGET}) #instead of set(CMAKE_C_COMPILER_TARGET ${TARGET})
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/zig-c++${SCRIPT_SUFFIX}" -target ${TARGET}) #instead of set(CMAKE_CXX_COMPILER_TARGET ${TARGET})
set(CMAKE_ASM_COMPILER "${CMAKE_C_COMPILER}")
set(CMAKE_AR "${CMAKE_CURRENT_LIST_DIR}/zig-ar${SCRIPT_SUFFIX}")
set(CMAKE_RANLIB "${CMAKE_CURRENT_LIST_DIR}/zig-ranlib${SCRIPT_SUFFIX}")
set(CMAKE_RC_COMPILER "${CMAKE_CURRENT_LIST_DIR}/zig-rc${SCRIPT_SUFFIX}")

# GCC is still needed to get libc for embedded target (newlib) and some command
set(GCC_PREFIX arm-none-eabi-)
set(CMAKE_OBJCOPY ${GCC_PREFIX}objcopy)
set(CMAKE_SIZE ${GCC_PREFIX}size)
#set(CMAKE_LINKER ${GCC_PREFIX}ld)
#set(CMAKE_STRIP ${GCC_PREFIX}strip)


set(CMAKE_EXECUTABLE_SUFFIX_ASM ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_C ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_CXX ".elf")

# Optionally reduce compiler sanity check when cross-compiling.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)




#TODO: Clang option for libc and libm + obj
set(GCC_ARM_SYSROOT "/opt/softs/xpack-arm-none-eabi-gcc-14.2.1-1.1/bin/../arm-none-eabi") # -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mcpu=cortex_m4 -print-sysroot 2>&1
set(GCC_ARM_VERSION "14.2.1") #-dumpversion 2>&1
set(GCC_ARM_MULTI_DIR "thumb/v7e-m+fp/hard") # -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mcpu=cortex_m4 -print-multi-directory 2>&1


set(GCC_ARM_OBJS
    ${GCC_ARM_SYSROOT}/../lib/gcc/arm-none-eabi/${GCC_ARM_VERSION}/${GCC_ARM_MULTI_DIR}/crti.o
    ${GCC_ARM_SYSROOT}/../lib/gcc/arm-none-eabi/${GCC_ARM_VERSION}/${GCC_ARM_MULTI_DIR}/crtbegin.o
    ${GCC_ARM_SYSROOT}/../lib/gcc/arm-none-eabi/${GCC_ARM_VERSION}/${GCC_ARM_MULTI_DIR}/crtn.o
    ${GCC_ARM_SYSROOT}/../lib/gcc/arm-none-eabi/${GCC_ARM_VERSION}/${GCC_ARM_MULTI_DIR}/crtend.o
    ${GCC_ARM_SYSROOT}/lib/${GCC_ARM_MULTI_DIR}/crt0.o
)

link_directories(
    ${GCC_ARM_SYSROOT}/../lib/gcc/arm-none-eabi/${GCC_ARM_VERSION}/${GCC_ARM_MULTI_DIR}
    ${GCC_ARM_SYSROOT}/lib/${GCC_ARM_MULTI_DIR}
)
include_directories(${GCC_ARM_SYSROOT}/include)


set_source_files_properties(
    ${GCC_ARM_OBJS}
    PROPERTIES
    EXTERNAL_OBJECT true
    GENERATED true
)



