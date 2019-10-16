class IgnitionTools1 < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-tools/get/277dda7b2c36ef87387fc571c4e717f41c14eb2b.tar.bz2"
  version "0.999.999~pre0~20190911~277dda7"
  sha256 "b45a82d27ae121e63aa0245d0649ccdc59b7c93d893bbbb05fccafaa394b1979"
  head "https://bitbucket.org/ignitionrobotics/ign-tools", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "ignition-cmake2" => :build

  conflicts_with "ignition-tools", :because => "Differing version of the same formula"

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
