class IgnitionMsgs < Formula
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "http://gazebosim.org/distributions/ign-msgs/releases/ignition-msgs-0.5.0.tar.bz2"
  sha256 "d27c4dacce646ef013965742ec2fea207677937f3e3264870fe64d112e655b09"
  revision 1

  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-msgs/releases"
    sha256 "6c152138cef486382e0bdc19e5201a9fe44e455cb360d817550ef076b728c70a" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on "ignition-math2"
  depends_on "ignition-tools" => :recommended
  depends_on "pkg-config" => :run
  depends_on "protobuf"
  depends_on "protobuf-c" => :build

  patch do
    # Fix for pkg-config file
    url "https://bitbucket.org/ignitionrobotics/ign-msgs/commits/e657fc2970f611df3a30570f78ec797366eac26e/raw/"
    sha256 "3a63ba7e302f482a43cca0272bd747c984690179563655ac4bb9ac7e55fe6154"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <ignition/msgs.hh>
      int main() {
        ignition::msgs::UInt32;
        return 0;
      }
    EOS
    system "pkg-config", "ignition-msgs0"
    cflags = `pkg-config --cflags ignition-msgs0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs0",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
