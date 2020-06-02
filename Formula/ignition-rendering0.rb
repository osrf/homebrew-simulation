class IgnitionRendering0 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering0-0.2.0.tar.bz2"
  sha256 "2935ec21e61d40e93d89540843d0317527b25a28b8cd750658edd619db45ff03"
  revision 1

  head "https://github.com/ignitionrobotics/ign-rendering", :branch => "ign-rendering0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "aeb2fb7172c3f2b19bb5d4d6bfc61890b97c3129e4a7468094ae4e72bfb40ab9" => :mojave
    sha256 "38ac694f6dc64e7918c9b3e535b6b8317220dc3481a8fe09c8c86f7f10fd0fdc" => :high_sierra
    sha256 "10ebd9c0c4f223688efed8e5256e91e87328d70880dd9031d5809d95ab2aaaa4" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => [:build, :test]

  depends_on "freeimage"
  depends_on "ignition-cmake1"
  depends_on "ignition-common2"
  depends_on "ignition-math5"
  depends_on "ogre1.9"

  patch do
    # Don't conflict with ignition-rendering1
    url "https://bitbucket.org/ignitionrobotics/ign-rendering/commits/8aaa4b8188cae5cd5082e46a05abde6bfcc7fbde/raw/"
    sha256 "87ca51e370faab94d2ff92bc3fde3d236fe5f264a582a5740e047d85818280a8"
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
