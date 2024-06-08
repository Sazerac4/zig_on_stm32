cmake_minimum_required(VERSION 3.22)

message("FreeRTOS library included")
set(PATH_OS ${CMAKE_CURRENT_LIST_DIR}/../Middlewares)
set(PATH_CONFIG ${CMAKE_CURRENT_LIST_DIR}/../Core/Inc)
set(OS_LIBRARY freertos)

# ##############################################################################
# Library
add_library(${OS_LIBRARY} STATIC ${os_layer})

# Sources
file(
  GLOB
  os_layer
  ${PATH_OS}/Third_Party/FreeRTOS/Source/*.c
  ${PATH_OS}/Third_Party/FreeRTOS/Source/portable/MemMang/heap_4.c
  ${PATH_OS}/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F/port.c)
target_sources(${OS_LIBRARY} PUBLIC ${os_layer})

# Include
set(os_layer_include
    ${PATH_CONFIG} ${PATH_OS}/Third_Party/FreeRTOS/Source/include
    ${PATH_OS}/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2
    ${PATH_OS}/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F)
target_include_directories(${OS_LIBRARY} PUBLIC ${os_layer_include})

# ##############################################################################
target_compile_definitions(
  ${OS_LIBRARY}
  PRIVATE # Language specific only
          $<$<COMPILE_LANGUAGE:C>:
          >
          $<$<COMPILE_LANGUAGE:CXX>:
          >
          $<$<COMPILE_LANGUAGE:ASM>:
          >
          # Configuration specific
          $<$<CONFIG:Debug>:
          DEBUG
          >
          $<$<CONFIG:Release>:
          NDEBUG
          >)

# ##############################################################################
target_compile_options(${OS_LIBRARY} PRIVATE ${CPU_PARAMETERS} -Og -g0)


