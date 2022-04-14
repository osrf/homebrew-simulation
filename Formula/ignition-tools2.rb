class IgnitionTools2 < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.4.1.tar.bz2"
  sha256 "2aa1f7999068ff9e01ad8029899fd00d575a95a2b7bd16c59e47f832eb47b1c6"
  license "Apache-2.0"
  head "https://github.com/ignitionrobotics/ign-tools.git", branch: "ign-tools1"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "cc38c02e39b95ea6a6b9052e3c28bf60647073c40c4cae41226583132e8b0456"
    sha256 cellar: :any, catalina: "9e4788d9840133d4ca28c12499e659213406bb6c3c28f7b100563d5042c7fe4e"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test

  def install
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
    ENV["IGN_CONFIG_PATH"] = testpath/"config/"
    system "#{bin}/ign", "test", "--versions"
  end
end
