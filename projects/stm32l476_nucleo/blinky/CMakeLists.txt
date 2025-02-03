cmake_minimum_required(VERSION 3.22)

####################################################################
# Core project settings
####################################################################
set(PROJ_PATH ${CMAKE_CURRENT_SOURCE_DIR})

project(
  "blinky"
  VERSION "0.1.0"
  DESCRIPTION "Blinky led test"
  HOMEPAGE_URL ""
  LANGUAGES C)
enable_language(C CXX ASM)
message("Build type: " ${CMAKE_BUILD_TYPE})
set(EXECUTABLE ${CMAKE_PROJECT_NAME})

# Setup compiler settings
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)


####################################################################

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
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_tim.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_tim_ex.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_uart.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_uart_ex.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_rcc.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_rcc_ex.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash_ex.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash_ramfunc.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_gpio.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_i2c.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_i2c_ex.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_dma.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_dma_ex.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr_ex.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_cortex.c
  ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_exti.c
)

set(src_core_startup_SRCS ${PROJ_PATH}/startup_stm32l476xx.s)

#
# Include directories
#
set(include_c_DIRS ${include_c_DIRS} ${PROJ_PATH}/Core/Inc
                   ${PROJ_PATH}/modules/app
                   ${PROJ_PATH}/modules/port
                   ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Inc
                   ${PROJ_PATH}/Drivers/STM32L4xx_HAL_Driver/Inc/Legacy
                   ${PROJ_PATH}/Drivers/CMSIS/Device/ST/STM32L4xx/Include
                   ${PROJ_PATH}/Drivers/CMSIS/Include
)
set(include_cxx_DIRS)
set(include_asm_DIRS)


#
# Link directories setup Must be before executable is added
#
set(link_DIRS)
link_directories(${EXECUTABLE} ${link_DIRS})

#
# Executable files
#
add_executable(${EXECUTABLE} ${GCC_ARM_OBJS} ${C_SOURCES} ${src_core_src_SRCS}
                             ${src_core_startup_SRCS})

#
# Add linked libraries for linker
#
set(link_LIBS)
target_link_libraries(${EXECUTABLE} ${link_LIBS})

#
# Project symbols
#
target_compile_definitions(
  ${EXECUTABLE}
  PRIVATE # Language specific only
          $<$<COMPILE_LANGUAGE:C>:
          DEBUG STM32L476xx USE_HAL_DRIVER
          >
          $<$<COMPILE_LANGUAGE:CXX>:
          >
          $<$<COMPILE_LANGUAGE:ASM>:
          DEBUG>
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

# Compiler options
target_compile_options(
  ${EXECUTABLE}
  PRIVATE -Wall
          -Wextra
          -Wshadow
          -Wundef
          -Wuninitialized # -Wmaybe-uninitialized
          -Wmissing-prototypes
          -Wno-ignored-qualifiers #-Wno-discarded-qualifiers
          -Wimplicit-fallthrough
          -Wunused-function
          -Werror=strict-prototypes
          -Wpointer-arith
          -Wno-error=cpp
          -Wuninitialized
          -Wunused-parameter
          -Wno-missing-field-initializers
          -Wtype-limits
          -Wsizeof-pointer-memaccess
          -Wno-format-nonliteral
          -Wno-cast-qual
          -Wunreachable-code
          -Wno-switch-default
          -Wno-switch-enum
          -Wreturn-type
          -Wmultichar
          -Wformat-security
          -Wignored-qualifiers
          -Wno-error=pedantic
          -Wno-sign-compare
          -Wdouble-promotion
          #-Wclobbered
          -Wdeprecated
          -Wempty-body
          -Wshift-negative-value
          #-Wstack-usage=512
          -Wunused-value
          -Wno-comment
          )

# Compiler options
target_compile_options(
  ${EXECUTABLE}
  PRIVATE
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

# Linker options
target_link_options(
  ${EXECUTABLE}
  PRIVATE
  -specs=nano.specs
  -T${PROJ_PATH}/stm32l476rgtx_flash.ld
  #-Wl,-Map=${CMAKE_PROJECT_NAME}.map,--cref (Unsupported)
  # -u _printf_float # STDIO float formatting support (remove if not used) (Unsupported)
  -Wl,--start-group
  -lc_nano  # (can't name it -lc directly)
  -lm
  -Wl,--end-group
  #-Wl,--print-memory-usage (Unsupported)
  -Wl,--gc-sections)


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

