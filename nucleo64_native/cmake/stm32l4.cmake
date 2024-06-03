cmake_minimum_required(VERSION 3.22)


set(PATH_DRIVERS ${CMAKE_CURRENT_LIST_DIR}/../Drivers)
message("BSP Layers included")

set(include_c_DIRS
    ${include_c_DIRS}
    ${PATH_DRIVERS}/STM32L4xx_HAL_Driver/Inc
    ${PATH_DRIVERS}/STM32L4xx_HAL_Driver/Inc/Legacy
    ${PATH_DRIVERS}/CMSIS/Device/ST/STM32L4xx/Include
    ${PATH_DRIVERS}/CMSIS/Include)

file(GLOB bsp_layer ${PATH_DRIVERS}/STM32L4xx_HAL_Driver/Src/*hal*.c)
set(C_SOURCES ${C_SOURCES} ${bsp_layer})

