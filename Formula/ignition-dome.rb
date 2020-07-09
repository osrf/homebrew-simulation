class IgnitionDome < Formula
  desc "Ignition dome collection"
  homepage "https://github.com/ignitionrobotics/ign-dome"
  head "https://github.com/ignitionrobotics/ign-dome", :branch => "master"

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools5"
  depends_on "ignition-gazebo4"
  depends_on "ignition-gui4"
  depends_on "ignition-launch3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs6"
  depends_on "ignition-physics3"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering4"
  depends_on "ignition-sensors4"
  depends_on "ignition-tools"
  depends_on "ignition-transport9"
  depends_on :macos => :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat10"

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  # Failing test in Mojave
  # test do
  # TODO: improve the testing
  #  system "#{bin}/ign", "gazebo", "--help"
  # end
end
