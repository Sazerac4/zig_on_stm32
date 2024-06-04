cmake_minimum_required(VERSION 3.22)

set(PATH_LIBRARY ${CMAKE_CURRENT_LIST_DIR}/../library)

# Library Component
set(include_c_DIRS ${include_c_DIRS})

file(GLOB library_files)
set(C_SOURCES ${C_SOURCES} ${library_files})
