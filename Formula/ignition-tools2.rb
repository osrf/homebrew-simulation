class IgnitionTools2 < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://github.com/ignitionrobotics/ign-tools.git", branch: "main"
  version "1.999.999~0~20220414"
  license "Apache-2.0"
  head "https://github.com/ignitionrobotics/ign-tools.git", branch: "ign-tools2"

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
