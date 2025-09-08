#!/bin/sh
# Copyright (C) 2024 Open Source Robotics Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# The script will print the bottled dependents from the osrf/simulation
# tap of a specified formula.
#
# Usage:
# $ ./bottled_dependents.sh <formula> [<bottle_tag>]
#
# For example, to print the bottled dependents of gz-msgs10 from the
# osrf/simulation tap for the current OS and CPU architecture:
#
# ./bottled_dependents.sh gz-msgs10
#
# To print the bottled dependents for a specific OS and CPU combination,
# pass a bottle tag as an additional parameter, for example:
#
# ./bottled_dependents.sh gz-msgs10 arm64_sonoma

FORMULA=${1}
BOTTLE_TAG=${2}

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
  echo "bottled_dependents.sh <formula> [<bottle_tag>]"
  exit 1
fi

if [ -n "${BOTTLE_TAG}" ]; then
  BOTTLE_FLAG="--tag"
fi

for f in $(brew uses ${FORMULA} --formulae --eval-all | grep ^osrf/simulation/)
do
  # brew unbottled prints "already bottled" for bottled formulae
  if brew unbottled $f ${BOTTLE_FLAG} ${BOTTLE_TAG} | grep --quiet "already bottled"; then
    echo $f
  fi
done
