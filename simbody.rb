class Simbody < Formula
  desc "Multibody physics API"
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/Simbody-3.5.3.tar.gz"
  sha256 "8005fbdb16c6475f98e13b8f1423b0e9951c193681c2b0d19ae5b711d7e24ec1"
  head "https://github.com/simbody/simbody.git", :branch => "master"

  bottle do
    root_url "http://gazebosim.org/distributions/simbody/releases"
    sha256 "69186db06f20a5dd3da38429cd96e3b5b8e900cb02bc1db6803f2d06435df09f" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pkg-config" => :run

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "doxygen"
      system "make", "install"
    end
  end

  patch do
    # Fix pkg-config file
    url "https://github.com/scpeters/simbody/commit/a37deef08af530b57601251900fadee0d0be6cfd.diff"
    sha256 "0b99f7b6df46ddcc43094b29ba834896490fe5a76ceaa15f646b3b4579fed51e"
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
