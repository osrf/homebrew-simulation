class GzTransport12 < Formula
  desc "Transport middleware for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-transport/releases/gz-transport-12.2.1.tar.bz2"
  sha256 "62fb97a722dea804da262610061688f675222d4e33a7a1a59868fdefe6ae2d92"
  license "Apache-2.0"
  revision 17

  head "https://github.com/gazebosim/gz-transport.git", branch: "gz-transport12"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "a3cde9c7923fae3f1a81876edc13b4bf5578e4441fe84d6c1b4dd966a9d8ba17"
    sha256 monterey: "110da31adad51f203624341da51d5c72e323db8a0e84d406c3c703babdad3ac6"
  end

  depends_on "doxygen" => [:build, :optional]

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "gz-cmake3"
  depends_on "gz-msgs9"
  depends_on "gz-tools2"
  depends_on "gz-utils2"
  depends_on macos: :mojave # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "tinyxml2"
  depends_on "zeromq"

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/transport12", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # test CLI executables
    system libexec/"gz/transport12/gz-transport-service"
    system libexec/"gz/transport12/gz-transport-topic"
    # build against API
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <gz/transport.hh>
      int main() {
        gz::transport::NodeOptions options;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(gz-transport12 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-transport12::gz-transport12)
    EOS
    system "pkg-config", "gz-transport12"
    # cflags = `pkg-config --cflags gz-transport12`.split
    # ldflags = `pkg-config --libs gz-transport12`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-o", "test"
    ENV["GZ_PARTITION"] = rand((1 << 32) - 1).to_s
    # system "./test"
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
