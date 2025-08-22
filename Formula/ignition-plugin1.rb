class IgnitionPlugin1 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/ign-plugin/releases/ignition-plugin-1.4.0.tar.bz2"
  sha256 "72c4ad15c24c628cd0410f7f605eff762e864df19f6716de44e9b57ca8808743"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-plugin.git", branch: "ign-plugin1"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sonoma: "8a33c0a7ff05a05c07c8fcc3c3e35c9bd65fabf0abfa1b55f8ac71c5bd0f0b87"
    sha256 cellar: :any, sonoma:       "f5b2ad4b8721da99877710d5122cea321b6426bf25c0d27a27eafee5643ad384"
    sha256 cellar: :any, ventura:      "2c9887d57d32fb9c58d9497d38c12889039a554290b49bcd9d229a577cbb99eb"
    sha256 cellar: :any, monterey:     "c6e836c62b75fcfee2bdf7a1b7bdd232b351591efaceef0e05b37c483cbbef83"
    sha256 cellar: :any, big_sur:      "712f0971c2fa85a07b4e5971d4801ad7f324cd644cd170a603e850c57c4a30cd"
    sha256 cellar: :any, catalina:     "fe41a0a740d6c61fc5dc145c89e43c9fc3476588c56b606786d7de122c3276f1"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-tools"
  depends_on macos: :high_sierra # c++17
  depends_on "pkgconf"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/plugin/Loader.hh>
      int main() {
        ignition::plugin::Loader loader;
        return loader.InterfacesImplemented().size();
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-plugin1 QUIET REQUIRED COMPONENTS loader)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-PLUGIN_LIBRARIES})
    EOS
    system "pkg-config", "ignition-plugin1-loader"
    cflags = `pkg-config --cflags ignition-plugin1-loader`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-plugin1-loader",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
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
