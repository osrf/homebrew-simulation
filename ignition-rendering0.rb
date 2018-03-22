class IgnitionRendering0 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-rendering"
  url "https://bitbucket.org/ignitionrobotics/ign-rendering/get/c2a8d5847cfea20079fbafe5a9b29ac5a7c41f3b.tar.gz"
  version "0.0.0~20180315~c2a8d58"
  sha256 "fcccaae4206cf984261919ad0218ddb72ea55356e76f4d8c518670fbc4ba1de6"

  head "https://bitbucket.org/ignitionrobotics/ign-rendering", :branch => "default", :using => :hg

  depends_on "cmake" => :build

  depends_on "freeimage"
  depends_on "ignition-cmake1"
  depends_on "ignition-common1"
  depends_on "ignition-math4"
  depends_on "ogre1.9"

  depends_on "pkg-config" => :run

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/common/Console.hh>
      #include <ignition/common/Image.hh>

      #include "ignition/rendering/Camera.hh"
      #include "ignition/rendering/Image.hh"
      #include "ignition/rendering/PixelFormat.hh"
      #include "ignition/rendering/RenderEngine.hh"
      #include "ignition/rendering/RenderingIface.hh"
      #include "ignition/rendering/Scene.hh"

      using namespace ignition;
      using namespace rendering;

      int main()
      {
        // override and make sure not to look for resources in installed share dir
        std::string projectSrcPath = PROJECT_SOURCE_PATH;
        std::string env = "IGN_RENDERING_RESOURCE_PATH=" +
          common::joinPaths(projectSrcPath, "src");
        putenv(const_cast<char *>(env.c_str()));

        // create and populate scene
        RenderEngine *engine = rendering::engine(_renderEngine);
        if (!engine)
        {
        igndbg << "Engine '" << _renderEngine
              << "' is not supported" << std::endl;
        return;
        }

        // add resources in build dir
        engine->AddResourcePath(
          common::joinPaths(std::string(PROJECT_BUILD_PATH), "src"));

        ScenePtr scene = engine->CreateScene("scene");
        ASSERT_TRUE(scene != nullptr);
        scene->SetAmbientLight(0.3, 0.3, 0.3);

        VisualPtr root = scene->RootVisual();

        CameraPtr camera = scene->CreateCamera();
      }
    EOS
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-rendering"
    cflags   = `pkg-config --cflags ignition-rendering`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
