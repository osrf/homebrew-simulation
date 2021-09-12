class DartsimAT6100 < Formula
  desc "Dynamic Animation and Robotics Toolkit (openrobotics port)"
  homepage "https://dartsim.github.io/"
  # OSRF's fork
  url "https://github.com/ignition-forks/dart/archive/175596b511adb55d831c0c3401ef50e2cb96a6f3.tar.gz"
  version "6.10.0~20210610~175596b511adb55d831c0c3401ef50e2cb96a6f3"
  sha256 "e974479f01dde55bcef3680b300e1506bcf2f5f4c14ea7b096e7906a4cb1c85b"
  license "BSD-2-Clause"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "89857384c8ee478871f0e98de120de2015ac1b52f062c5c676f08e07fb598cab"
    sha256 mojave:   "ed52c065d410e68eb934357af9ead6f5b34c83386aa087759379b63b1913e9fe"
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

  patch do
    # Fix for compatibility with ipopt 3.13
    url "https://github.com/scpeters/dart/commit/d8500b7ee4d672ede22fbbbd72ef66c003aa2b6f.patch?full_index=1"
    sha256 "3c85f594b477ff2357017364a55cdc7b3ffa25ab53f08bd910ed5db71083ed6d"
  end

  patch do
    # Fix syntax error in glut_human_joint_limits/CMakeLists.txt
    url "https://github.com/dartsim/dart/commit/47274b551bd48a31a702b4ddc7c1f8061daef3d9.patch?full_index=1"
    sha256 "030e16a5728e856d0cc1788494da50272c52a7efec5c2a93e95de2cda7407f23"
  end

  def install
    ENV.cxx11
    args = std_cmake_args

    if OS.mac?
      # Force to link to system GLUT (see: https://cmake.org/Bug/view.php?id=16045)
      glut_lib = "#{MacOS.sdk_path}/System/Library/Frameworks/GLUT.framework"
      args << "-DGLUT_glut_LIBRARY=#{glut_lib}"
    end

    mkdir "build" do
      system "cmake", "..", *args, "-DCMAKE_INSTALL_RPATH=#{rpath}"
      system "make", "install"
    end

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
