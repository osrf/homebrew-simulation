class GzTools2 < Formula
  desc "Entry point for Gazebo command-line tools"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-tools/releases/gz-tools-2.0.1.tar.bz2"
  sha256 "0a99277ebad5494736be0fd9c39c27a62e8a9e97663c63a0be5957a94253e659"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-tools.git", branch: "gz-tools2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "32b6467d80e69475231f265e2682d2b9a6ec8ac1d97c8f3d5698e270b5f42d51"
    sha256 cellar: :any, monterey: "9b58977cd94e79fb870db54a8c9f4431e5319681687964e9a09310d616af5c2e"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test
  depends_on "gz-cmake3"

  conflicts_with "gazebo9", because: "both install bin/gz"
  conflicts_with "gazebo11", because: "both install bin/gz"

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
