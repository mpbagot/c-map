cmake_minimum_required(VERSION 2.8)
project(zip)
enable_language(C)
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

if (MSVC)
  # Use secure functions by defaualt and suppress warnings about "deprecated" functions
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES=1")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT=1")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D _CRT_NONSTDC_NO_WARNINGS=1 /D _CRT_SECURE_NO_WARNINGS=1")
elseif ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU" OR
        "${CMAKE_C_COMPILER_ID}" STREQUAL "Clang" OR
        "${CMAKE_C_COMPILER_ID}" STREQUAL "AppleClang")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -Wall -Wextra -Werror -pedantic")
endif (MSVC)

# zip
set(SRC zip_src/miniz.h zip_src/zip.h zip_src/zip.c)
add_library(${PROJECT_NAME} ${SRC})
target_include_directories(${PROJECT_NAME} INTERFACE src)

# uninstall target (https://gitlab.kitware.com/cmake/community/wikis/FAQ#can-i-do-make-uninstall-with-cmake)
if(NOT TARGET uninstall)
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake"
        IMMEDIATE @ONLY)

    add_custom_target(uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake)
endif()
