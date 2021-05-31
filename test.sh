#!/bin/bash

set -e

pushd build && ctest && popd

pushd Test && ./runtests && popd
