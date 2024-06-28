#!/usr/bin/env bash

# Copyright (c) 2018 Patrick Hohenecker
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# author:   Patrick Hohenecker <mail@paho.at>
# version:  2018.1
# date:     May 15, 2018

GREEN='\033[0;32m'
NC='\033[0m' # No Color

INSTALL_FOLDER="/usr/local"  # the location to look for CUDA installations at
TARGET_VERSION=${1}          # the target CUDA version to switch to (if provided)
CURRENT_VERSION=$(nvcc --version | sed -n 's/^.*release \([0-9]\+\.[0-9]\+\).*$/\1/p')

# if no version to switch to has been provided, then just print all available CUDA installations
if [[ -z ${TARGET_VERSION} ]]; then
    echo "The following CUDA installations have been found (in '${INSTALL_FOLDER}'):"
    ls -l "${INSTALL_FOLDER}" | egrep -o "cuda-[0-9]+\\.[0-9]+$" | while read -r line; do
    if [[ "$(echo ${line} | sed 's/cuda-//')" == "$CURRENT_VERSION" ]]; then
            echo -e "${GREEN}* ${line}${NC}"
        else
            echo "  ${line}"
        fi
    done
    set +e
    exit 0
# otherwise, check whether there is an installation of the requested CUDA version
elif [[ ! -d "${INSTALL_FOLDER}/cuda-${TARGET_VERSION}" ]]; then
    echo "No installation of CUDA ${TARGET_VERSION} has been found!"
    set +e
    exit 0
fi

# the path of the installation to use
NEW_CUDA_PATH="${INSTALL_FOLDER}/cuda-${TARGET_VERSION}"

FILE_PATH="${HOME}/.bashrc"

new_path_line="export PATH=${NEW_CUDA_PATH}/bin\${PATH:+:\${PATH}}"
new_ld_library_path_line="export LD_LIBRARY_PATH=${NEW_CUDA_PATH}/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}"

# Replace or add  export ligne PATH
if grep -q "^export PATH=/usr/local/cuda-[0-9]\+\.[0-9]\+/bin" "$FILE_PATH"; then
  sed -i "s|^export PATH=/usr/local/cuda-[0-9]\+\.[0-9]\+/bin.*|$new_path_line|" "$FILE_PATH"
else
  echo "$new_path_line" >> "$FILE_PATH"
fi

if grep -q "^export LD_LIBRARY_PATH=/usr/local/cuda-[0-9]\+\.[0-9]\+/lib64" "$FILE_PATH"; then
  sed -i "s|^export LD_LIBRARY_PATH=/usr/local/cuda-[0-9]\+\.[0-9]\+/lib64.*|$new_ld_library_path_line|" "$FILE_PATH"
else
  echo "$new_ld_library_path_line" >> "$FILE_PATH"
fi

echo "Switched to CUDA ${TARGET_VERSION}."

exec bash

set +e
exit 0

