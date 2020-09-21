class DartsimAT6100 < Formula
  desc "Dynamic Animation and Robotics Toolkit (openrobotics port)"
  homepage "https://dartsim.github.io/"
  # osrc custom nightly built from commit fdde7e7894ebc36bae8811f7a63e5b1c899bb4af
  url "https://github.com/azeey/dart/archive/1673b0be51fb370023df7490dc49706b590d8f72.tar.gz"
  version "6.10.0~20200916~1673b0be51fb370023df7490dc49706b590d8f72"
  sha256 "ec2e833d3225ac3f4365cc6d8b2f5511170a47d140ff43dcc7d63a50fbb6bfd5"
  license "BSD-2-Clause"
  revision 3

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "1ffd432953added3124f5c5637694d86671dfcb783635450731ea4352af9f03b" => :mojave
    sha256 "df64e9d8765fc3099e9c51d0bc4e52c1e86dcb058799a79d22c272bb0044b8a1" => :high_sierra
  end

  keg_only "open robotics fork of dart HEAD + custom changes"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "assimp"
  depends_on "boost"
  depends_on "bullet"
  depends_on "eigen"
  depends_on "fcl"
  depends_on "flann"
  depends_on "ipopt"
  depends_on "libccd"
  depends_on "nlopt"
  depends_on "ode"
  depends_on "open-scene-graph"
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def install
    ENV.cxx11

    # Force to link to system GLUT (see: https://cmake.org/Bug/view.php?id=16045)
    system "cmake", ".", "-DGLUT_glut_LIBRARY=/System/Library/Frameworks/GLUT.framework",
                         *std_cmake_args
    system "make", "install"

    # Add rpath to shared libraries
    Dir[lib/"libdart*.6.10.0.dylib"].each do |l|
      macho = MachO.open(l)
      macho.add_rpath(opt_lib.to_s)
      macho.write!
    end

    # Clean up the build file garbage that has been installed.
    rm_r Dir["#{share}/doc/dart/**/CMakeFiles/"]
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <dart/dart.hpp>
      int main() {
        auto world = std::make_shared<dart::simulation::World>();
        assert(world != nullptr);
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{Formula["eigen"].include}/eigen3",
                    "-I#{include}", "-L#{lib}", "-ldart",
                    "-L#{Formula["assimp"].opt_lib}", "-lassimp",
                    "-L#{Formula["boost"].opt_lib}", "-lboost_system",
                    "-std=c++14", "-o", "test"
    ENV.append_path "DYLD_FALLBACK_LIBRARY_PATH", Formula["dartsim@6.10.0"].opt_lib
    ENV.append_path "DYLD_FALLBACK_LIBRARY_PATH", Formula["assimp"].opt_lib
    ENV.append_path "DYLD_FALLBACK_LIBRARY_PATH", Formula["octomap"].opt_lib
    system "./test"
  end
end
