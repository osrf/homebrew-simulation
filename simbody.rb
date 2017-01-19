class Simbody < Formula
  desc "Multibody physics API"
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/Simbody-3.5.4.tar.gz"
  sha256 "449c36e574d6f859d4fa8854ab6bc8e402e5ca5894bcce3e9fdce2f5658d64de"
  head "https://github.com/simbody/simbody.git", :branch => "master"
  revision 1

  bottle do
    root_url "http://gazebosim.org/distributions/simbody/releases"
    sha256 "e37ea67010f856dbe63b52a8136ad468c3d3dc48eead2ee3e7227abdbb55dd19" => :el_capitan
    sha256 "374b70963d6d5336eccaa83427a1acf0c938b97b618a10a7c1181fdcf06f1c09" => :yosemite
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
