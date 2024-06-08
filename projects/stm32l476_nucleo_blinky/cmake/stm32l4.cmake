cmake_minimum_required(VERSION 3.22)

set(PATH_DRIVERS ${CMAKE_CURRENT_LIST_DIR}/../Drivers)
set(PATH_CONFIGS ${CMAKE_CURRENT_LIST_DIR}/../Core/Inc)
message("Hal library included")
set(DRIVERS_LIBRARY ll_drivers)

# ##############################################################################
# Library
add_library(${DRIVERS_LIBRARY} STATIC ${os_layer})

# Sources
file(GLOB driver_srcs ${PATH_DRIVERS}/STM32L4xx_HAL_Driver/Src/*.c)
list(
  REMOVE_ITEM
  driver_srcs
  "${PATH_DRIVERS}/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_msp_template.c"
  "${PATH_DRIVERS}/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_timebase_tim_template.c"
)
target_sources(${DRIVERS_LIBRARY} PUBLIC ${driver_srcs})

# Include
set(driver_includes
    ${PATH_CONFIGS}
    ${PATH_DRIVERS}/STM32L4xx_HAL_Driver/Inc
    ${PATH_DRIVERS}/STM32L4xx_HAL_Driver/Inc/Legacy
    ${PATH_DRIVERS}/CMSIS/Device/ST/STM32L4xx/Include
    ${PATH_DRIVERS}/CMSIS/Include)
target_include_directories(${DRIVERS_LIBRARY} PUBLIC ${driver_includes})

# ##############################################################################
target_compile_definitions(${DRIVERS_LIBRARY} PRIVATE "NDEBUG")

target_compile_definitions(
  ${DRIVERS_LIBRARY}
  PUBLIC # Language specific only
         $<$<COMPILE_LANGUAGE:C>:
         "STM32L476xx"
         "USE_HAL_DRIVER"
         >
         $<$<COMPILE_LANGUAGE:CXX>:
         >
         $<$<COMPILE_LANGUAGE:ASM>:
         >)

# ##############################################################################
target_compile_options(${DRIVERS_LIBRARY} PRIVATE ${CPU_PARAMETERS} -Og -g0)
