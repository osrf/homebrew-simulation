class BoostAT1850 < Formula
  desc "Collection of portable C++ source libraries"
  homepage "https://www.boost.org/"
  url "https://github.com/boostorg/boost/releases/download/boost-1.85.0/boost-1.85.0-b2-nodocs.tar.xz"
  sha256 "09f0628bded81d20b0145b30925d7d7492fd99583671586525d5d66d4c28266a"
  license "BSL-1.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "fb79af23638d60be500f32f88cf179626a1284c30b1a6b1c802fe3c8c7faf7dd"
    sha256 cellar: :any, ventura: "d30d0028956faa275279b6f83e36844d8f6cea128c75114bd204ea162ce4acae"
  end

  keg_only :versioned_formula

  depends_on "icu4c@76"
  depends_on "xz"
  depends_on "zstd"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  def install
    # Force boost to compile with the desired compiler
    open("user-config.jam", "a") do |file|
      if OS.mac?
        file.write "using darwin : : #{ENV.cxx} ;\n"
      else
        file.write "using gcc : : #{ENV.cxx} ;\n"
      end
    end

    # libdir should be set by --prefix but isn't
    icu4c = deps.find { |dep| dep.name.match?(/^icu4c(@\d+)?$/) }
                .to_formula
    bootstrap_args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      --with-icu=#{icu4c.opt_prefix}
    ]

    # Handle libraries that will not be built.
    without_libraries = ["python", "mpi"]

    # Boost.Log cannot be built using Apple GCC at the moment. Disabled
    # on such systems.
    without_libraries << "log" if ENV.compiler == :gcc

    bootstrap_args << "--without-libraries=#{without_libraries.join(",")}"

    # layout should be synchronized with boost-python and boost-mpi
    args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      -d2
      -j#{ENV.make_jobs}
      --layout=tagged-1.66
      --user-config=user-config.jam
      install
      threading=multi,single
      link=shared,static
    ]

    # Boost is using "clang++ -x c" to select C compiler which breaks C++
    # handling in superenv. Using "cxxflags" and "linkflags" still works.
    # C++17 is due to `icu4c`.
    args << "cxxflags=-std=c++17"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang

    system "./bootstrap.sh", *bootstrap_args
    system "./b2", "headers"
    system "./b2", *args
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <boost/algorithm/string.hpp>
      #include <boost/iostreams/device/array.hpp>
      #include <boost/iostreams/device/back_inserter.hpp>
      #include <boost/iostreams/filter/zstd.hpp>
      #include <boost/iostreams/filtering_stream.hpp>
      #include <boost/iostreams/stream.hpp>

      #include <string>
      #include <iostream>
      #include <vector>
      #include <assert.h>

      using namespace boost::algorithm;
      using namespace boost::iostreams;
      using namespace std;

      int main()
      {
        string str("a,b");
        vector<string> strVec;
        split(strVec, str, is_any_of(","));
        assert(strVec.size()==2);
        assert(strVec[0]=="a");
        assert(strVec[1]=="b");

        // Test boost::iostreams::zstd_compressor() linking
        std::vector<char> v;
        back_insert_device<std::vector<char>> snk{v};
        filtering_ostream os;
        os.push(zstd_compressor());
        os.push(snk);
        os << "Boost" << std::flush;
        os.pop();

        array_source src{v.data(), v.size()};
        filtering_istream is;
        is.push(zstd_decompressor());
        is.push(src);
        std::string s;
        is >> s;

        assert(s == "Boost");

        return 0;
      }
    CPP
    system ENV.cxx, "test.cpp", "-std=c++14", "-o", "test", "-I#{include}",
                    "-L#{lib}", "-lboost_iostreams", "-L#{Formula["zstd"].opt_lib}", "-lzstd"
    system "./test"
  end
end
