# Tutorial:
# https://kubasejdak.com/how-to-cross-compile-for-embedded-with-cmake-like-a-champ
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
message("Use arm-none-eabi-gcc as compiler")
# Some default GCC settings arm-none-eabi- must be part of path environment
set(TOOLCHAIN_PREFIX arm-none-eabi-)
set(FLAGS "-fdata-sections -ffunction-sections")
set(CPP_FLAGS "${FLAGS} -fno-rtti -fno-exceptions -fno-threadsafe-statics")
set(CMAKE_C_FLAGS ${FLAGS})
set(CMAKE_CXX_FLAGS ${CPP_FLAGS})


set(CMAKE_AR ${TOOLCHAIN_PREFIX}ar)
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)
set(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}ranlib)
set(CMAKE_LINKER ${TOOLCHAIN_PREFIX}ld)
set(CMAKE_STRIP ${TOOLCHAIN_PREFIX}strip)

# set(CMAKE_C_FLAGS               <c_flags>) set(CMAKE_CXX_FLAGS <cpp_flags>)
# set(CMAKE_C_FLAGS_DEBUG         <c_flags_for_debug>) set(CMAKE_C_FLAGS_RELEASE
# <c_flags_for_release>) set(CMAKE_CXX_FLAGS_DEBUG       <cpp_flags_for_debug>)
# set(CMAKE_CXX_FLAGS_RELEASE     <cpp_flags_for_release>)
# set(CMAKE_EXE_LINKER_FLAGS      <linker_flags>)

set(CMAKE_EXECUTABLE_SUFFIX_ASM ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_C ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_CXX ".elf")

# Optionally reduce compiler sanity check when cross-compiling.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
