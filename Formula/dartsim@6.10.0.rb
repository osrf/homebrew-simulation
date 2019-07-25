class DartsimAT6100 < Formula
  desc "Dynamic Animation and Robotics Toolkit (openrobotics port)"
  homepage "https://dartsim.github.io/"
  # osrc custom nightly built from commit fdde7e7894ebc36bae8811f7a63e5b1c899bb4af
  url "https://github.com/azeey/dart/archive/fdde7e7894ebc36bae8811f7a63e5b1c899bb4af.tar.gz"
  version "6.10.0~20190718~fdde7e7894ebc36bae8811f7a63e5b1c899bb4af"
  sha256 "2083a5a52a8376d1c99c33423a64c35c80fec97825cb1ed65f1d09e74a3940c7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "50f451b0e902ee01fc189405fa92af7a26c10370bce95a7a09c8f2dcf980debb" => :mojave
    sha256 "befffe7a4dda18a3dcb0bf02d8ff27c22a07e2c1ade14f0f3d6ff7d0fcab781b" => :high_sierra
    sha256 "96a5c68065937e4b0b919388da078c75433edd5d2a088d23296890d84ae023ba" => :sierra
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
    ENV.append_path "DYLD_FALLBACK_LIBRARY_PATH", Formula["octomap"].opt_lib
    system "./test"
  end
end
