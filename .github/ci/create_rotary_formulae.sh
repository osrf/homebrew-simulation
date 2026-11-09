#!/bin/sh

for j in $(ls Aliases/gz-jetty-* | grep -v launch)
do
  p=$(basename $j | sed -e 's@.*gz-jetty-@@')
  # set `r` to rotary formula path, like Formula/gz-rotary-math.rb
  r=Formula/$(basename $j | sed -e 's@gz-jetty-@gz-rotary-@' -e 's@[0-9]*@@').rb
  # copy jetty formula to rotary and fix class name, dependencies, and head branch
  brew cat $(basename $j) > ${r}
  sed -e 's@class Gz\([A-Za-z]*\)[0-9]*@class GzRotary\1@' \
      -e 's@class Sdformat[0-9]*@class GzRotarySdformat@' \
      -e 's@\(depends_on "gz-\)\([a-z_-]*\)[0-9]*"@\1rotary-\2"@' \
      -e 's@\(depends_on "sdformat\)[0-9]*"@depends_on "gz-rotary-sdformat"@' \
      -e 's@gz-gui-10@gz-gui@' \
      -e 's@gz-physics-9@gz-physics@' \
      -e 's@gz-rendering-10@gz-rendering@' \
      -e 's@gz-sim-10@gz-sim@' \
      -e 's@gz/plugin4@gz/plugin@' \
      -e 's@gz/sim10@gz/sim@' \
      -e 's@gz/transport15@gz/transport@' \
      -e 's@\(Formula\["gz-\)\([a-z_-]*\)[0-9]*"@\1rotary-\2"@' \
      -e 's@^.*head\( .* branch: "\).*$@  head\1main"@' \
      -i -- ${r}
  # remove bottle block
  brew bump-revision ${r} --remove-bottle-block --write-only
  # remove unneeded lines
  sed -e '/^  url /d' \
      -e '/^  sha256 /d' \
      -e '/^  revision /d' \
      -e '/^  conflicts_with "gz-rotary-/d' \
      -e '/^  depends_on "freeimage"/d' \
      -e '/qt@5/d' \
      -i -- ${r}
  # add conflicts_with
  sed -e '/^  def install/i \
  conflicts_with "", because: "both install gz-"\

' -i -- ${r}
  sed -e "s@conflicts_with \"\",.*@conflicts_with \"$(basename $j)\", because: \"both install gz-${p}\"@" \
    -i -- ${r}
  # add caveats
  sed -e '/^  test do/i \
  def caveats\
    <<~EOS\
      This is an unstable, development version of Gazebo built from source.\
    EOS\
  end\

' -i -- ${r}

  # add matching conflicts_with to jetty if not already present
  if ! grep 'conflicts_with "gz-rotary-' ${j} > /dev/null ; then
    sed -e '/^  def install/i \
  conflicts_with "", because: "both install gz-"\

' -i -- Aliases/$(readlink ${j})
    sed -e "s@conflicts_with \"\".*@conflicts_with \"gz-rotary-${p}\", because: \"both install gz-${p}\"@" \
      -i -- Aliases/$(readlink ${j})
  fi

  # create symlink for next numbered version to rotary formula
  f=$(basename $(readlink $j) | sed -e 's@\.rb@@')
  n=$(echo $f | sed -e 's@[^0-9]*@@')
  next=$(python3 -c "print($n + 1)")
  f_next=$(echo $f | sed -e "s@$n@$next@")
  ln -s ../${r} Aliases/${f_next}
done

brew style --fix Formula/gz-rotary-*
