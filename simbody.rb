class Simbody < Formula
  desc "Multibody physics API"
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/Simbody-3.5.4.tar.gz"
  sha256 "449c36e574d6f859d4fa8854ab6bc8e402e5ca5894bcce3e9fdce2f5658d64de"
  revision 2

  head "https://github.com/simbody/simbody.git", :branch => "master"

  bottle do
    root_url "http://gazebosim.org/distributions/simbody/releases"
    sha256 "bb2932af0b11a96c634876267a7628f08ae77057f1c1b6d19703328b098c7b84" => :high_sierra
    sha256 "68c5aacc1f0f1b14811cd8b342303a7ee2bc204065517d9d7439507e5016e7f9" => :sierra
    sha256 "68f86436ddad44b6fd0ebbe5aaf36ed67e13a79c9bf0b336440843ac03e1228b" => :el_capitan
    sha256 "5ae2d17b898aa6884cd7db5c1d85709e9cb25e2de06a6b188d64adc50e964eff" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pkg-config" => :run

  def install
    # Don't use 10.11 SDK frameworks on 10.10 with xcode7
    ENV.delete("MACOSX_DEPLOYMENT_TARGET")
    ENV.delete("SDKROOT")
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "doxygen"
      system "make", "install"
    end
  end

  patch do
    # Fix pkg-config file
    url "https://github.com/scpeters/simbody/commit/a37deef08af530b57601251900fadee0d0be6cfd.diff?full_index=1"
    sha256 "67cf07b493f908f7fc27323b16ff4bbbd796f287744d9a53088806effb920cd1"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "simbody/Simbody.h"
      using namespace SimTK;
      int main() {
        // Create the system.
        MultibodySystem system;
        SimbodyMatterSubsystem matter(system);
        GeneralForceSubsystem forces(system);
        Force::UniformGravity gravity(forces, matter, Vec3(0, -9.8, 0));
        Body::Rigid pendulumBody(MassProperties(1.0, Vec3(0), Inertia(1)));
        pendulumBody.addDecoration(Transform(), DecorativeSphere(0.1));
        MobilizedBody::Pin pendulum1(matter.Ground(), Transform(Vec3(0)),
                                     pendulumBody, Transform(Vec3(0, 1, 0)));
        MobilizedBody::Pin pendulum2(pendulum1, Transform(Vec3(0)),
                                     pendulumBody, Transform(Vec3(0, 1, 0)));
        // Initialize the system and state.
        system.realizeTopology();
        State state = system.getDefaultState();
        pendulum2.setRate(state, 5.0);
        // Simulate it.
        RungeKuttaMersonIntegrator integ(system);
        TimeStepper ts(system, integ);
        ts.initialize(state);
        ts.stepTo(50.0);
      }
    EOS
    system "pkg-config", "simbody"
    flags = `pkg-config --cflags --libs simbody`.split(" ")
    system ENV.cxx, "test.cpp", *flags, "-o", "test"
    system "./test"
  end
end
