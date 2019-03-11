class IgnitionRendering0 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering0-0.2.0.tar.bz2"
  sha256 "2935ec21e61d40e93d89540843d0317527b25a28b8cd750658edd619db45ff03"

  head "https://bitbucket.org/ignitionrobotics/ign-rendering", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "1c42940411174299ace55010dfe94c99765715164f15b9922ac605394da15b08" => :mojave
    sha256 "884996d9ea7ed00e4fdd0956d0d30a1165f9947cba68c7823d459093c2cfb7d2" => :high_sierra
    sha256 "9a7104b9edc472f6cdd8e6a9aa398b651cef8fba2bfcdca40a0c21ce1c432533" => :sierra
  end

  depends_on "cmake" => :build

  depends_on "freeimage"
  depends_on "ignition-cmake1"
  depends_on "ignition-common2"
  depends_on "ignition-math5"
  depends_on "ogre1.9"
  depends_on "pkg-config"

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
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/rendering/PixelFormat.hh>
      int main(int _argc, char** _argv)
      {
        ignition::rendering::PixelFormat pf = ignition::rendering::PF_UNKNOWN;
        return ignition::rendering::PixelUtil::IsValid(pf);
      }
    EOS
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-rendering0"
    cflags   = `pkg-config --cflags ignition-rendering0`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
