#!/bin/bash

RELEASE_TOOLS_REPO="https://github.com/gazebo-tooling/release-tools"
generated_jobs="$(mktemp -d)/generated_jobs.txt"
curl --location "${RELEASE_TOOLS_REPO}/raw/master/jenkins-scripts/dsl/logs/generated_jobs.txt" \
  --output "${generated_jobs}"

JOB_URL='https://build.osrfoundation.org/job/'
BADGE_URL='https://build.osrfoundation.org/buildStatus/icon?job='
arches=( \
  amd64 \
  arm64 \
)
collections=( \
  fortress \
  harmonic \
  ionic \
  jetty \
  rotary \
)
packages=( \
  gz-cmake \
  gz-common \
  gz-fuel-tools \
  gz-gui \
  gz-launch \
  gz-math \
  gz-msgs \
  gz-physics \
  gz-plugin \
  gz-rendering \
  gz-sensors \
  gz-sim \
  gz-tools \
  gz-transport \
  gz-utils \
  sdformat \
)

# print table of badges
# one row for each package / arch
# one column for each collection
# Status        | Arch | Fortress | Harmonic | Ionic | Jetty
echo -n "Status        | Arch"
for c in ${collections[@]};
do
  echo -n " | $c"
done
echo
# ------------- | ---- | -------- | -------- | ----- | -------
echo -n "------------- | ----"
for c in ${collections[@]};
do
  echo -n " | $(echo $c | tr '[:print:]' '-')"
done
echo
for p in ${packages[@]};
do
  p_=$(echo $p | tr '-' '_')
  designation=$(echo $p_ | sed -e 's@^gz_@@')
  for arch in ${arches[@]};
  do
    echo -n "[$p][$designation-repo] | $(echo ${arch} | sed -e 's@amd64@intel@')"
    for c in ${collections[@]};
    do
      if [ "$c" = "rotary" ] && [ "$designation" = "launch" ]; then
        echo -n " |"
      else
        #         | [![Build Status][cmake-fortress-amd64-badge]][cmake-fortress-amd64]
        echo -n " | [![Build Status][$designation-$c-$arch-badge]][$designation-$c-$arch]"
      fi
    done
    # print blank line at end of row for each package / arch combination
    echo
  done
done
# print row of collection install jobs
for arch in ${arches[@]};
do
  echo -n "collection | $(echo ${arch} | sed -e 's@amd64@intel@')"
  for c in ${collections[@]};
  do
      #         | [![Build Status][cmake-fortress-amd64-badge]][cmake-fortress-amd64]
      echo -n " | [![Build Status][collection-$c-$arch-badge]][collection-$c-$arch]"
  done
  # print blank line at end of row for each arch
  echo
done

# print extra blank line
echo

# define URLs for each package
for p in ${packages[@]};
do
  p_=$(echo $p | tr '-' '_')
  designation=$(echo $p_ | sed -e 's@^gz_@@')
  echo "[${designation}-repo]: https://github.com/gazebosim/${p}"
  for arch in ${arches[@]};
  do
    grep "^install_ci [a-z]* \(gz_rotary_${designation}\|${p_}\).*homebrew-${arch}" ${generated_jobs} \
      | awk -v arch="$arch" \
            -v badge_url="${BADGE_URL}" \
            -v designation="$designation" \
            -v job_url="${JOB_URL}" \
            '{print "[" designation "-" $2 "-" arch "]: " job_url $3 "\n" \
                    "[" designation "-" $2 "-" arch "-badge]: " badge_url $3;}'
  done
  # print a blank line between packages
  echo
done

# define URLs for each collection
for c in ${collections[@]};
do
  for arch in ${arches[@]};
  do
    grep "^install_ci [a-z]* gz_${c}-install.*homebrew-${arch}" ${generated_jobs} \
      | awk -v arch="$arch" \
            -v badge_url="${BADGE_URL}" \
            -v job_url="${JOB_URL}" \
            '{print "[collection-" $2 "-" arch "]: " job_url $3 "\n" \
                    "[collection-" $2 "-" arch "-badge]: " badge_url $3;}'
  done
done

# print a blank line at the end
echo
