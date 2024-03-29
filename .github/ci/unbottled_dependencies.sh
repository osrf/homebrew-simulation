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

# The script will print the unbottled dependencies from the osrf/simulation
# tap of a specified formula.
#
# Usage:
# $ ./unbottled_dependencies.bash <formula>
#
# For example, to print the unbottled dependencies of gz-harmonic from the
# osrf/simulation tap:
#
# ./unbottled_dependencies.bash gz-harmonic

FORMULA=${1}

if [ $# -ne 1 ]; then
  echo "./unbottled_dependencies.bash <formula>"
  exit 1
fi

for f in $(brew deps ${FORMULA} --full-name | grep ^osrf/simulation/)
do
  # brew unbottled prints "already bottled" for bottled formulae
  # but has different output for formulae that are "ready to bottle" or
  # that have "unbottled deps". So just echo the name of any formula for which
  # `brew unbottled` doesn't print "already bottled"
  if ! brew unbottled $f | grep --quiet "already bottled"; then
    echo $f
  fi
done
