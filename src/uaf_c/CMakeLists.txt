cmake_minimum_required(VERSION 3.8)

project(UAF)

set(CMAKE_C_FLAGS "-m32")
add_executable(uaf uaf.c)
