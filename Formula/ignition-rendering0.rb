class IgnitionRendering0 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering0-0.2.0.tar.bz2"
  sha256 "2935ec21e61d40e93d89540843d0317527b25a28b8cd750658edd619db45ff03"
  license "Apache-2.0"
  revision 1

  head "https://github.com/ignitionrobotics/ign-rendering", branch: "ign-rendering0"

  depends_on "cmake" => :build
  depends_on "pkg-config" => [:build, :test]

  depends_on "freeimage"
  depends_on "ignition-cmake1"
  depends_on "ignition-common2"
  depends_on "ignition-math5"
  depends_on "ogre1.9"

  patch do
    # Don't conflict with ignition-rendering1
    url "https://github.com/ignitionrobotics/ign-rendering/commit/ba788c7261d367e3f1d72d62ee57ad8a32602bc1.diff?full_index=1"
    sha256 "41710795b494e86b983dae5c97e604f38a605d29f638f1386474bd3f348879fb"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    azure = !ENV["HOMEBREW_AZURE_PIPELINES"].nil?
    travis = !ENV["HOMEBREW_TRAVIS_CI"].nil?
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/rendering/RenderEngine.hh>
      #include <ignition/rendering/RenderingIface.hh>
      int main(int _argc, char** _argv)
      {
        ignition::rendering::RenderEngine *engine =
            ignition::rendering::engine("ogre");
        return engine == nullptr;
      }
    EOS
    system "pkg-config", "ignition-rendering0"
    cflags   = `pkg-config --cflags ignition-rendering0`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test" unless azure || travis
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
