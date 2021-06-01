cmake_minimum_required(VERSION 3.8)

project(UAF)

set(CMAKE_C_FLAGS "-ansi -D_SVID_SOURCE -DOSS_AUDIO -D'ARCH=\"$host_cpu\"'")
add_executable(uaf uaf.c)
