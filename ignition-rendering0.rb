class IgnitionRendering0 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-rendering"
  url "https://bitbucket.org/ignitionrobotics/ign-rendering/get/02471846d59963f171540b1d0767efa944b82224.tar.gz"
  version "0.0.0~20180629~0247184"
  sha256 "4691349e7859f313ddf2bbc0647cef560d05f6ef24b7a764731277111e40a281"

  head "https://bitbucket.org/ignitionrobotics/ign-rendering", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-rendering/releases"
    sha256 "8b8c253114e3c6af1d6978e79b02c3c10895a5fe276a21570e370eaa4252491d" => :high_sierra
    sha256 "520b171c51d0415f99ae7c8ecdd955249d166bad89edcad83879b85735c9a80f" => :sierra
    sha256 "42acd100d3187950a56ec3fde87349feb78368d7c3552a9a1344f0c031511f72" => :el_capitan
  end

  depends_on "cmake" => :build

  depends_on "freeimage"
  depends_on "ignition-cmake1"
  depends_on "ignition-common2"
  depends_on "ignition-math5"
  depends_on "ogre1.9"
  depends_on "pkg-config"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <vector>

      #include <ignition/common/Console.hh>
      #include <ignition/rendering.hh>

      using namespace ignition;
      using namespace rendering;

      void buildScene(ScenePtr _scene)
      {
        // initialize _scene
        _scene->SetAmbientLight(0.3, 0.3, 0.3);
        VisualPtr root = _scene->RootVisual();

        // create directional light
        DirectionalLightPtr light0 = _scene->CreateDirectionalLight();
        light0->SetDirection(-0.5, 0.5, -1);
        light0->SetDiffuseColor(0.5, 0.5, 0.5);
        light0->SetSpecularColor(0.5, 0.5, 0.5);
        root->AddChild(light0);

        // create point light
        PointLightPtr light2 = _scene->CreatePointLight();
        light2->SetDiffuseColor(0.5, 0.5, 0.5);
        light2->SetSpecularColor(0.5, 0.5, 0.5);
        light2->SetLocalPosition(3, 5, 5);
        root->AddChild(light2);

        // create green material
        MaterialPtr green = _scene->CreateMaterial();
        green->SetAmbient(0.0, 0.5, 0.0);
        green->SetDiffuse(0.0, 0.7, 0.0);
        green->SetSpecular(0.5, 0.5, 0.5);
        green->SetShininess(50);
        green->SetReflectivity(0);

        // create center visual
        VisualPtr center = _scene->CreateVisual();
        center->AddGeometry(_scene->CreateSphere());
        center->SetLocalPosition(3, 0, 0);
        center->SetLocalScale(0.1, 0.1, 0.1);
        center->SetMaterial(green);
        root->AddChild(center);

        // create red material
        MaterialPtr red = _scene->CreateMaterial();
        red->SetAmbient(0.5, 0.0, 0.0);
        red->SetDiffuse(1.0, 0.0, 0.0);
        red->SetSpecular(0.5, 0.5, 0.5);
        red->SetShininess(50);
        red->SetReflectivity(0);

        // create sphere visual
        VisualPtr sphere = _scene->CreateVisual();
        sphere->AddGeometry(_scene->CreateSphere());
        sphere->SetOrigin(0.0, -0.5, 0.0);
        sphere->SetLocalPosition(3, 0, 0);
        sphere->SetLocalRotation(0, 0, 0);
        sphere->SetLocalScale(1, 2.5, 1);
        sphere->SetMaterial(red);
        root->AddChild(sphere);

        // create blue material
        MaterialPtr blue = _scene->CreateMaterial();
        blue->SetAmbient(0.0, 0.0, 0.3);
        blue->SetDiffuse(0.0, 0.0, 0.8);
        blue->SetSpecular(0.5, 0.5, 0.5);
        blue->SetShininess(50);
        blue->SetReflectivity(0);

        // create box visual
        VisualPtr box = _scene->CreateVisual();
        box->AddGeometry(_scene->CreateBox());
        box->SetOrigin(0.0, 0.5, 0.0);
        box->SetLocalPosition(3, 0, 0);
        box->SetLocalRotation(M_PI / 4, 0, M_PI / 3);
        box->SetLocalScale(1, 2.5, 1);
        box->SetMaterial(blue);
        root->AddChild(box);

        // create white material
        MaterialPtr white = _scene->CreateMaterial();
        white->SetAmbient(0.5, 0.5, 0.5);
        white->SetDiffuse(0.8, 0.8, 0.8);
        white->SetReceiveShadows(true);
        white->SetReflectivity(0);

        // create plane visual
        VisualPtr plane = _scene->CreateVisual();
        plane->AddGeometry(_scene->CreatePlane());
        plane->SetLocalScale(5, 8, 1);
        plane->SetLocalPosition(3, 0, -0.5);
        plane->SetMaterial(white);
        root->AddChild(plane);

        // create camera
        CameraPtr camera = _scene->CreateCamera("camera");
        camera->SetLocalPosition(0.0, 0.0, 0.0);
        camera->SetLocalRotation(0.0, 0.0, 0.0);
        camera->SetImageWidth(800);
        camera->SetImageHeight(600);
        camera->SetAntiAliasing(2);
        camera->SetAspectRatio(1.333);
        camera->SetHFOV(M_PI / 2);
        root->AddChild(camera);
      }

      CameraPtr createCamera(const std::string &_engineName)
      {
        // create and populate scene
        RenderEngine *engine = rendering::engine(_engineName);
        if (!engine)
        {
          std::cout << "Engine '" << _engineName
                    << "' is not supported" << std::endl;
          return CameraPtr();
        }
        ScenePtr scene = engine->CreateScene("scene");
        buildScene(scene);

        // return camera sensor
        SensorPtr sensor = scene->SensorByName("camera");
        return std::dynamic_pointer_cast<Camera>(sensor);
      }

      int main(int _argc, char** _argv)
      {
        common::Console::SetVerbosity(4);
        std::vector<std::string> engineNames;
        std::vector<CameraPtr> cameras;

        engineNames.push_back("ogre");
        engineNames.push_back("optix");
        for (auto engineName : engineNames)
        {
          try
          {
            CameraPtr camera = createCamera(engineName);
            if (camera)
            {
              cameras.push_back(camera);
            }
          }
          catch (...)
          {
            // std::cout << ex.what() << std::endl;
            std::cerr << "Error starting up: " << engineName << std::endl;
          }
        }
        return 0;
      }
    EOS
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-rendering0"
    cflags   = `pkg-config --cflags ignition-rendering0`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
