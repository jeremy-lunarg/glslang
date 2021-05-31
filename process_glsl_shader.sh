#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -o errexit

# The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no
# command exited with a non-zero status.
set -o pipefail

# Disallow existing regular files to be overwritten by redirection of output.
set -o noclobber

# Treat unset variables as an error when substituting.
set -o nounset

# Check for correct number of command line arguments.
if [ $# -ne 2 ];
then
	echo "$0 <target environment> <glsl file>"
	exit 1
fi

# Check if command line arguments are set.
if [ -z ${1+x} ];
then
	echo "$0 <target environment> <glsl file>"
	exit 1
fi
target_environment="$1"

# The SPIR-V validator takes slightly different strings as arguments to target environment.
spirv_val_target_environment="$target_environment"
if [ "$target_environment" = "spirv1.0" ]; then
	spirv_val_target_environment="spv1.0"
elif [ "$target_environment" = "spirv1.1" ]; then
	spirv_val_target_environment="spv1.1"
elif [ "$target_environment" = "spirv1.2" ]; then
	spirv_val_target_environment="spv1.2"
elif [ "$target_environment" = "spirv1.3" ]; then
	spirv_val_target_environment="spv1.3"
elif [ "$target_environment" = "spirv1.4" ]; then
	spirv_val_target_environment="spv1.4"
elif [ "$target_environment" = "spirv1.5" ]; then
	spirv_val_target_environment="spv1.5"
fi

if [ -z ${2+x} ];
then
	echo "$0 <target environment> <glsl file>"
	exit 1
fi
glsl_file="$2"

# Check if the HLSL file exits.
if [ ! -f "$glsl_file" ];
then
	echo "$glsl_file does not exist"
	exit 1
fi

# Debug:
# cgdb --args ./glslangValidator -V --target-env "$target_environment" -e main -o "$glsl_file.spv" "$glsl_file"

./glslangValidator -V --target-env "$target_environment" -e main -o "$glsl_file.spv" "$glsl_file"
./glslangValidator -H --target-env "$target_environment" -e main "$glsl_file" | tail -n +2 >| "$glsl_file.spv.human"
./spirv-dis -o "$glsl_file.spv.dis" "$glsl_file.spv"
./spirv-val --target-env "$spirv_val_target_environment" "$glsl_file.spv"
