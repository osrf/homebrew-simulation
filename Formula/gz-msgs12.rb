class GzMsgs12 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-12.0.2.tar.bz2"
  sha256 "cca452d55937998330801fbef97e3cfdb6298e6807bb53b64fbd826266950bb6"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs12"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "d086078ccb36b0717afaf3a0f1883c9b7a251f2c60a3ad02c1df6cb175cfc5bd"
    sha256 arm64_sonoma:  "5584a8100d29bc388a0ab491593cbcf31926e35a91a235d2d3228ed78d27e549"
    sha256 sonoma:        "8e007b99be2ec190b2269a8e56a2d06d6a18ad426a4797dd12ad41def7f94d4c"
  end

  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake5"
  depends_on "gz-math9"
  depends_on "gz-tools2"
  depends_on "gz-utils4"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "tinyxml2"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def python_cmake_arg(python = Formula["python@3.13"])
    "-DPython3_EXECUTABLE=#{python.opt_libexec}/bin/python"
  end

  conflicts_with "gz-rotary-msgs", because: "both install gz-msgs"

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/msgs", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"
    cmake_args << python_cmake_arg

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    # this installs python files for each message that can be used by multiple
    # versions of python, so symlink the files to versioned python folders
    pythons.each do |python|
      # remove @ from formula name
      python_name = python.name.tr("@", "")
      # symlink the python files directly instead of the parent folder to avoid
      # brew link errors if there is a pre-existing __pycache__ folder
      (lib/"#{python_name}/site-packages/gz/msgs").install_symlink Dir[lib/"python/gz/msgs/*"]
    end
  end

  test do
    system libexec/"gz/msgs/gz-msgs"
    (testpath/"test.cpp").write <<-EOS
      #include <gz/msgs.hh>
      int main() {
        gz::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-msgs QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-msgs::gz-msgs)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-msgs"
    cflags = `pkg-config --cflags gz-msgs`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-msgs",
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
    # check python import
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", "import gz.msgs"
    end
    system formula_opt_libexec("python3")/"bin/python", "-c", "import gz.msgs"
    # check gz msg command
    ENV["GZ_CONFIG_PATH"] = "#{opt_share}/gz"
    system formula_opt_bin("gz-tools2")/"gz", "msg"
  end
end
