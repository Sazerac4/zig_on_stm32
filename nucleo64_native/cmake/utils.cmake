cmake_minimum_required(VERSION 3.22)
message("Bluetech utils included")

# ##############################################################################
# ##############################################################################
# ##############################################################################
# Helper function to add preprocesor definition of FILE_BASENAME to pass the
# filename without directory path for debugging use.
#
# Note that in header files this is not consistent with __FILE__ and __LINE__
# since FILE_BASENAME will be the compilation unit source file name (.c/.cpp).
# NAME or NAME_WE (with or without extension)
#
# Example:
#
# define_file_basename_for_sources(my_target)
#
# Will add -D__FILENAME__="filename" for each source file depended on by
# my_target, where filename is the name of the file.
#
function(define_file_basename_for_sources targetname)
  get_target_property(source_files "${targetname}" SOURCES)
  foreach(sourcefile ${source_files})
    # Add the FILE_BASENAME=filename compile definition to the list.
    get_filename_component(output_name "${sourcefile}" NAME_WE)
    # Set the updated compile definitions on the source file.
    set_property(
      SOURCE "${sourcefile}"
      APPEND
      PROPERTY COMPILE_DEFINITIONS "__FILENAME__=\"${output_name}\"")
  endforeach()
endfunction()

# ##############################################################################
# ##############################################################################
# ##############################################################################

find_package(Git)
if(Git_FOUND)
  # Generate a git-describe version string from Git repository tags
  message("Git found: ${GIT_EXECUTABLE}")
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --abbrev=7 --dirty --always --tags
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE git_tag
    RESULT_VARIABLE GIT_DESCRIBE_ERROR_CODE
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --short -q HEAD
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE git_commit
    RESULT_VARIABLE GIT_DESCRIBE_ERROR_CODE
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT GIT_DESCRIBE_ERROR_CODE)
    set(__VERSION_FULL__ ${GIT_DESCRIBE_VERSION})
  endif()
endif()


# Final fallback: Just use a bogus version string that is semantically older
# than anything else and spit out a warning to the developer.
if(NOT DEFINED git_tag)
  set(git_tag 0.0.0-unknown)
  message(
    WARNING
      "Failed to determine git_tag from Git tags. Using default version \"${git_tag}\"."
  )
endif()

if(git_tag
   MATCHES
   "(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)(-[.0-9A-Za-z-]+)?([+][.0-9A-Za-z-]+)?$"
)
else()
  message(WARNING "Git tag isn't valid semantic version: [${git_tag}]")
  set(git_tag 0.0.0-unknown)
  string(REGEX MATCH "(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)(-[.0-9A-Za-z-]+)?([+][.0-9A-Za-z-]+)?$" _ ${git_tag})
  message(WARNING "Using placeholder git tag : [${git_tag}]")
endif()

set(GIT_MAJOR "${CMAKE_MATCH_1}")
set(GIT_MINOR "${CMAKE_MATCH_2}")
set(GIT_PATCH "${CMAKE_MATCH_3}")
set(identifiers "${CMAKE_MATCH_4}")
set(metadata "${CMAKE_MATCH_5}")
set(GIT_SEMVER ${GIT_MAJOR}.${GIT_MINOR}.${GIT_PATCH})
set(GIT_COMMIT ${git_commit})
set(GIT_VERSION_COMPLETE ${GIT_SEMVER}${identifiers}${metadata})
