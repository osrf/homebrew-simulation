class GzTools2 < Formula
  desc "Entry point for Gazebo command-line tools"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-tools/releases/gz-tools-2.0.3.tar.bz2"
  sha256 "49f5308856928ee1327fe167948b45ae593794d0a40f4be59fc3d51caa4eeb22"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-tools.git", branch: "gz-tools2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sonoma: "f52c0a3cc13c4e8152297d0d1b1a6898b2c01e4065f4ed5e8149850dc62d07cb"
    sha256 cellar: :any, sonoma:       "6eab67f804cc9881a492eaa605d03de81c89b8dcb1c97363767610614c33d6dd"
    sha256 cellar: :any, ventura:      "e606d064f2808df0c288387da842166d2cc0a85066094c9111d20c9c3faaa3dc"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test
  depends_on "gz-cmake3"

  conflicts_with "gazebo11", because: "both install bin/gz"
  conflicts_with "gz-tools3", because: "both install bin/gz"

  def install
    inreplace "src/gz.in" do |s|
      s.gsub! "@CMAKE_INSTALL_PREFIX@", HOMEBREW_PREFIX
    end

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    mkdir testpath/"config"
    (testpath/"config/test.yaml").write <<~EOS
      --- # Test subcommand
      format: 1.0.0
      library_name: test
      library_path: path
      library_version: 2.0.0
      commands:
          - test  : Test utility
      ---
    EOS
    ENV["GZ_CONFIG_PATH"] = testpath/"config/"
    system "#{bin}/gz", "test", "--versions"
  end
end
