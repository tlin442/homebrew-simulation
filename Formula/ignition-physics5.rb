class IgnitionPhysics5 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-physics"
  url "https://osrf-distributions.s3.amazonaws.com/ign-physics/releases/ignition-physics5-5.0.0.tar.bz2"
  sha256 "4470791e5785087ee310618d04c821db6494ee50b72137263bb469e2f3f217b6"
  license "Apache-2.0"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "0448022dbf0c55285c505b24c11777ea4df1e8057cbee3d5d914abdc52cb9534"
    sha256 cellar: :any, catalina: "3d141ab5757716df5d1499e2d043b122dd1bf1588d9656671dde7ead7390b7c1"
  end

  depends_on "cmake" => :build

  depends_on "bullet"
  depends_on "dartsim@6.10.0"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on "ignition-utils1"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat12"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "ignition/plugin/Loader.hh"
      #include "ignition/physics/ConstructEmpty.hh"
      #include "ignition/physics/RequestEngine.hh"
      int main()
      {
        ignition::plugin::Loader loader;
        loader.LoadLib("#{opt_lib}/libignition-physics5-dartsim-plugin.dylib");
        ignition::plugin::PluginPtr dartsim =
            loader.Instantiate("ignition::physics::dartsim::Plugin");
        using featureList = ignition::physics::FeatureList<
            ignition::physics::ConstructEmptyWorldFeature>;
        auto engine =
            ignition::physics::RequestEngine3d<featureList>::From(dartsim);
        return engine == nullptr;
      }
    EOS
    system "pkg-config", "ignition-physics5"
    cflags   = `pkg-config --cflags ignition-physics5`.split
    ldflags  = `pkg-config --libs ignition-physics5`.split
    system "pkg-config", "ignition-plugin1-loader"
    loader_cflags   = `pkg-config --cflags ignition-plugin1-loader`.split
    loader_ldflags  = `pkg-config --libs ignition-plugin1-loader`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   *loader_cflags,
                   *loader_ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
