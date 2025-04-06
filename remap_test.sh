#!/bin/bash

set -e

reset

rm -rf remap_test
mkdir remap_test

# TODO: Why doesn't -Od disable optimizations?

function process_source() {
      local SHADER_FILE=$1
      local GLSLANG_OPTIONS=$2
      local REMAP_OPTIONS=$3

      ./build/StandAlone/glslang \
            ${GLSLANG_OPTIONS} \
            -o ./remap_test/${SHADER_FILE}.spv \
            ./Test/${SHADER_FILE} \
            > ./remap_test/${SHADER_FILE}.spv.human.txt
      ./spirv-dis --raw-id -o ./remap_test/${SHADER_FILE}.spv.txt \
            ./remap_test/${SHADER_FILE}.spv
      ./build/StandAlone/spirv-remap ${REMAP_OPTIONS} \
            -i ./remap_test/${SHADER_FILE}.spv \
            -o ./remap_test/${SHADER_FILE}.remap.spv \
            > ./remap_test/${SHADER_FILE}.remap.trace.txt
      ./spirv-dis --raw-id -o ./remap_test/${SHADER_FILE}.remap.spv.txt \
            ./remap_test/${SHADER_FILE}.remap.spv
      ./spirv-diff ./remap_test/${SHADER_FILE}.spv \
            ./remap_test/${SHADER_FILE}.remap.spv \
            > ./remap_test/${SHADER_FILE}.spirv-diff.txt
      # use diff ... || : to ignore diff failures
      diff -y ./remap_test/${SHADER_FILE}.spv.txt \
            ./remap_test/${SHADER_FILE}.remap.spv.txt \
            > ./remap_test/${SHADER_FILE}.diff.txt || :
}

function process_spv() {
      local SHADER_FILE=${1%.*}
      local GLSLANG_OPTIONS=$2
      local REMAP_OPTIONS=$3

      cp ./Test/${SHADER_FILE}.spv ./remap_test/${SHADER_FILE}.spv
      ./spirv-dis --raw-id -o ./remap_test/${SHADER_FILE}.spv.txt \
            ./remap_test/${SHADER_FILE}.spv
      ./build/StandAlone/spirv-remap ${REMAP_OPTIONS} \
            -i ./remap_test/${SHADER_FILE}.spv \
            -o ./remap_test/${SHADER_FILE}.remap.spv \
            > ./remap_test/${SHADER_FILE}.remap.trace.txt
      ./spirv-dis --raw-id -o ./remap_test/${SHADER_FILE}.remap.spv.txt \
            ./remap_test/${SHADER_FILE}.remap.spv
      # spirv-diff doesn't like the "*.literal64.*" shaders; use diff instead
      # use diff ... || : to ignore diff failures
      diff -y ./remap_test/${SHADER_FILE}.spv.txt \
            ./remap_test/${SHADER_FILE}.remap.spv.txt \
            > ./remap_test/${SHADER_FILE}.diff.txt || :
}

GLSLANG_OPTIONS="-V -Od -e main -H --aml --amb"

SHADER_FILE="remap.basic.none.frag"
REMAP_VERBOSITY="5"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY}"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.basic.everything.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.basic.dcefunc.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --dce funcs"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.basic.strip.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --strip"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.specconst.comp"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.switch.none.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY}"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.switch.everything.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.literal64.none.spv"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY}"
{ # Spawn subshells to run in parallel.
process_spv "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.literal64.everything.spv"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
process_spv "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remapper_input.spv"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
process_spv "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.if.none.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY}"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.if.everything.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.similar_1a.none.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY}"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.similar_1b.none.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY}"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

# TODO: Analyze large diff.
SHADER_FILE="remap.similar_1a.everything.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

# TODO: Analyze large diff.
SHADER_FILE="remap.similar_1b.everything.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.uniformarray.none.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY}"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

# TODO: Analyze large diff.
SHADER_FILE="remap.uniformarray.everything.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

# Update command line options for HLSL.
GLSLANG_OPTIONS="-D -V -Od -e main -H --aml --amb"

SHADER_FILE="remap.hlsl.sample.basic.strip.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --strip"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

# TODO: Analyze large diff.
SHADER_FILE="remap.hlsl.sample.basic.everything.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.hlsl.sample.basic.none.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY}"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

SHADER_FILE="remap.hlsl.templatetypes.none.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY}"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &

# TODO: Analyze large diff.
SHADER_FILE="remap.hlsl.templatetypes.everything.frag"
REMAP_OPTIONS="--verbose ${REMAP_VERBOSITY} --do-everything"
{ # Spawn subshells to run in parallel.
      process_source "${SHADER_FILE}" "${GLSLANG_OPTIONS}" "${REMAP_OPTIONS}"
} &