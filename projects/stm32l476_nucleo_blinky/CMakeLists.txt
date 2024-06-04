cmake_minimum_required(VERSION 3.22)


####################################################################
# Core project settings
####################################################################
set(PROJ_PATH ${CMAKE_CURRENT_SOURCE_DIR})
include(${PROJ_PATH}/cmake/utils.cmake)

project(
  "blinky"
  VERSION "${GIT_SEMVER}"
  DESCRIPTION "Blinky led test"
  HOMEPAGE_URL ""
  LANGUAGES C)
enable_language(C CXX ASM)
message("Build type: " ${CMAKE_BUILD_TYPE})

# Setup compiler settings
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)


####################################################################
#
# Core MCU flags, CPU, instruction set and FPU setup
#
set(CPU_PARAMETERS
    -mthumb
    # Other parameters -mcpu, -mfloat, -mfloat-abi, ...
    -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mcpu=cortex-m4)

####################################################################

#Add bsp layer
include(${PROJ_PATH}/cmake/stm32l4.cmake)


#
# User flags
#
set(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} \
    -Wshadow  \
    -Wundef  \
    -Wmaybe-uninitialized  \
    -Wmissing-prototypes  \
    -Wno-discarded-qualifiers  \
    -Wimplicit-fallthrough  \
    -Wunused-function  \
    -Werror=strict-prototypes  \
    -Wpointer-arith  \
    -Wno-error=cpp  \
    -Wuninitialized  \
    -Wunused-parameter  \
    -Wno-missing-field-initializers  \
    -Wtype-limits  \
    -Wsizeof-pointer-memaccess  \
    -Wno-format-nonliteral  \
    -Wno-cast-qual  \
    -Wunreachable-code  \
    -Wno-switch-default  \
    -Wno-switch-enum  \
    -Wreturn-type  \
    -Wmultichar  \
    -Wformat-security  \
    -Wignored-qualifiers  \
    -Wno-error=pedantic  \
    -Wno-sign-compare  \
    -Wdouble-promotion  \
    -Wclobbered  \
    -Wdeprecated  \
    -Wempty-body  \
    -Wshift-negative-value  \
    -Wstack-usage=512  \
    -Wunused-value  \
    -Wno-comment \
    -Wall \
    -Wextra")

set(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} \
    -fno-strict-aliasing")

# Set linker script
set(linker_script_SRC ${PROJ_PATH}/STM32L476RGTx_FLASH.ld)
set(EXECUTABLE ${CMAKE_PROJECT_NAME})

#
# Source files
#
file(
  GLOB
  src_core_src_SRCS
  ${PROJ_PATH}/Core/Src/usart.c
  ${PROJ_PATH}/Core/Src/system_stm32l4xx.c
  ${PROJ_PATH}/Core/Src/stm32l4xx_it.c
  ${PROJ_PATH}/Core/Src/stm32l4xx_hal_msp.c
  ${PROJ_PATH}/Core/Src/main.c
  ${PROJ_PATH}/Core/Src/gpio.c
  ${PROJ_PATH}/Core/Src/sysmem.c
  ${PROJ_PATH}/Core/Src/syscalls.c
  )

set(src_core_startup_SRCS ${PROJ_PATH}/startup_stm32l476xx.s)

#
# Include directories
#
set(include_c_DIRS ${include_c_DIRS} ${PROJ_PATH}/Core/Inc
                   ${PROJ_PATH}/modules/app ${PROJ_PATH}/modules/port)
set(include_cxx_DIRS)
set(include_asm_DIRS)


# Symbols definition
#
set(symbols_c_SYMB ${symbols_c_SYMB} "DEBUG" "STM32L476xx" "USE_HAL_DRIVER")
set(symbols_c_SYMB
    ${symbols_c_SYMB}
    "__VERSION_FULL__=\"${GIT_VERSION_COMPLETE}\""
    "__VERSION_MAJOR__=${GIT_MAJOR}"
    "__VERSION_MINOR__=${GIT_MINOR}"
    "__VERSION_PATCH__=${GIT_PATCH}"
    "__VERSION_RC__=0"
    "__GIT_COMMIT_SHORT__=\"${git_commit}\""
    "__APP_NAME__=\"${CMAKE_PROJECT_NAME}\""
    "__DOXYGEN__=0")

set(symbols_cxx_SYMB)
set(symbols_asm_SYMB "DEBUG")

#
# Link directories setup Must be before executable is added
#
set(link_DIRS)
link_directories(${EXECUTABLE} ${link_DIRS})

#
# Executable files
#
add_executable(${EXECUTABLE} ${C_SOURCES} ${src_core_src_SRCS}
                             ${src_core_startup_SRCS})

#
# Add linked libraries for linker
#
set(link_LIBS ll_drivers)
target_link_libraries(${EXECUTABLE} ${link_LIBS})

#
# Project symbols
#
target_compile_definitions(
  ${EXECUTABLE}
  PRIVATE # Language specific only
          $<$<COMPILE_LANGUAGE:C>:
          ${symbols_c_SYMB}>
          $<$<COMPILE_LANGUAGE:CXX>:
          ${symbols_cxx_SYMB}>
          $<$<COMPILE_LANGUAGE:ASM>:
          ${symbols_asm_SYMB}>
          # Configuration specific
          $<$<CONFIG:Debug>:
          DEBUG
          >
          $<$<CONFIG:Release>:
          NDEBUG
          >)

#
# Add include paths for each of the compiler
#
target_include_directories(
  ${EXECUTABLE}
  PRIVATE # Language specific only
          $<$<COMPILE_LANGUAGE:C>:
          ${include_c_DIRS}>
          $<$<COMPILE_LANGUAGE:CXX>:
          ${include_cxx_DIRS}>
          $<$<COMPILE_LANGUAGE:ASM>:
          ${include_asm_DIRS}>
          # Configuration specific
          $<$<CONFIG:Debug>:
          >
          $<$<CONFIG:Release>:
          >)

# Compiler and linker options
target_compile_options(
  ${EXECUTABLE}
  PRIVATE ${CPU_PARAMETERS}
          $<$<COMPILE_LANGUAGE:C>:
          >
          $<$<COMPILE_LANGUAGE:CXX>:
          >
          $<$<COMPILE_LANGUAGE:ASM>:
          -x
          assembler-with-cpp
          -MMD
          -MP
          >
          $<$<CONFIG:Debug>:
          -Og
          -g3
          -ggdb
          >
          $<$<CONFIG:Release>:
          -Og
          -g0
          -flto=4
          >)

target_link_options(
  ${EXECUTABLE}
  PRIVATE
  -specs=nano.specs
  -T${linker_script_SRC}
  ${CPU_PARAMETERS}
  -Wl,-Map=${CMAKE_PROJECT_NAME}.map,--cref
  -u _printf_float # STDIO float formatting support (remove if not used)
  -Wl,--undefined=uxTopUsedPriority
  -Wl,--start-group
  -lc
  -lm
  #-lnosys
  -Wl,--end-group
  -Wl,--print-memory-usage
  -Wl,--gc-sections)

# Add custom __FILENAME__ for each app sources files.
define_file_basename_for_sources(${EXECUTABLE})

# Execute post-build to print size
add_custom_command(
  TARGET ${EXECUTABLE}
  POST_BUILD
  COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${EXECUTABLE}>)

# Convert output to hex and binary
add_custom_command(
  TARGET ${EXECUTABLE}
  POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${EXECUTABLE}>
          ${EXECUTABLE}.hex)

# Convert to bin file -> add conditional check?
add_custom_command(
  TARGET ${EXECUTABLE}
  POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${EXECUTABLE}>
          ${EXECUTABLE}.bin)

# Final message
add_custom_target(
  FinalMessage ALL
  COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan
          "Compilation is done ! Compiler version: ${CMAKE_C_COMPILER_VERSION}"
  COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan
          "Gis tag is         : ${GIT_VERSION_COMPLETE}"
  COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan
          "Semantic version is: ${GIT_SEMVER}"
  # COMMENT "Final Message"
)
add_dependencies(FinalMessage ${EXECUTABLE})
