class GzTools2 < Formula
  desc "Entry point for Gazebo command-line tools"
  homepage "https://gazebosim.org"
  url "https://github.com/gazebosim/gz-tools.git", branch: "gz-tools2"
  version "1.999.999~0~20220414"
  license "Apache-2.0"

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test
  depends_on "gz-cmake3"

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
    ENV["GZ_CONFIG_PATH"] = testpath/"config/"
    system "#{bin}/gz", "test", "--versions"
  end
end
