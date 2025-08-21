class GzTools2 < Formula
  desc "Entry point for Gazebo command-line tools"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-tools/releases/gz-tools-2.0.2.tar.bz2"
  sha256 "82147f328c601ec2a88fa1fbdd42f89c7558b6943315d5599434fd4a189c39d7"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-tools.git", branch: "gz-tools2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "6eab67f804cc9881a492eaa605d03de81c89b8dcb1c97363767610614c33d6dd"
    sha256 cellar: :any, ventura: "e606d064f2808df0c288387da842166d2cc0a85066094c9111d20c9c3faaa3dc"
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
