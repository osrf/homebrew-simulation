class GzMsgs11 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-11.1.0.tar.bz2"
  sha256 "2343f0975d00fb21dd87de15603161981c920e0e4b33e735863a259f488f36d0"
  license "Apache-2.0"
  revision 17

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "9d690b93a590ef6e452349e98a24b629b4a2f5b50d4585282cb3987e27c87ed3"
    sha256 arm64_sonoma:  "7540a599fd4f32306fb50678f69171a2e57138a248693b6e4f3b7c068c4b57b5"
    sha256 sonoma:        "5c0ea2240375fc93a669aff6107fc4e9da0bdae53e7d5ea0477eda7e714cd3ac"
  end

  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake4"
  depends_on "gz-math8"
  depends_on "gz-tools2"
  depends_on "gz-utils3"
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

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/msgs11", target: lib),
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
      (lib/"#{python_name}/site-packages/gz/msgs11").install_symlink Dir[lib/"python/gz/msgs11/*"]
    end
  end

  test do
    system libexec/"gz/msgs11/gz-msgs"
    (testpath/"test.cpp").write <<-EOS
      #include <gz/msgs.hh>
      int main() {
        gz::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-msgs11 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-msgs11::gz-msgs11)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-msgs11"
    cflags = `pkg-config --cflags gz-msgs11`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-msgs11",
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
      system python.opt_libexec/"bin/python", "-c", "import gz.msgs11"
    end
    system Formula["python3"].opt_libexec/"bin/python", "-c", "import gz.msgs11"
  end
end
