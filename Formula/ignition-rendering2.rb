class IgnitionRendering2 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-rendering"
  url "https://bitbucket.org/ignitionrobotics/ign-rendering/get/95a38eb155b92ebb4419d7a4377dcfe2d183e0a2.tar.bz2"
  version "1.999.999~20190311~95a38eb1"
  sha256 "83571fff709752a66049bc1a16b90ecfbd3425a9bd82bf52cd598ae9f7310156"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "freeimage"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on :macos => :high_sierra # c++17
  depends_on "ogre1.9"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/rendering/PixelFormat.hh>
      int main(int _argc, char** _argv)
      {
        ignition::rendering::PixelFormat pf = ignition::rendering::PF_UNKNOWN;
        return ignition::rendering::PixelUtil::IsValid(pf);
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(ignition-rendering2 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-rendering2::ignition-rendering2)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-rendering2"
    cflags   = `pkg-config --cflags ignition-rendering2`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering2`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
