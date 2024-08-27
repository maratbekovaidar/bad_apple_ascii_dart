# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(bad_apple_ascii_dart_library VERSION 0.0.1 LANGUAGES C)

add_library(bad_apple_ascii_dart SHARED
  "bad_apple_ascii_dart.c"
)

set_target_properties(bad_apple_ascii_dart PROPERTIES
  PUBLIC_HEADER bad_apple_ascii_dart.h
  OUTPUT_NAME "bad_apple_ascii_dart"
)

target_compile_definitions(bad_apple_ascii_dart PUBLIC DART_SHARED_LIB)
