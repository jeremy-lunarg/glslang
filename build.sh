#!/bin/bash

set -e

#TODO: Keep gtest updated.

./update_glslang_sources.py

cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX=build/install

cmake --build build --target install -- -j`nproc`
