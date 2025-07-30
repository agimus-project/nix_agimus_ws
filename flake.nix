{
  description = "CHANGEME";

  inputs = {
    gepetto.url = "github:nim65s/gepetto-nix/gz";
    flake-parts.follows = "gepetto/flake-parts";
    gazebo-sim-overlay.follows = "gepetto/gazebo-sim-overlay";
    nixpkgs.follows = "gepetto/nixpkgs";
    nix-ros-overlay.follows = "gepetto/nix-ros-overlay";
    systems.follows = "gepetto/systems";
    treefmt-nix.follows = "gepetto/treefmt-nix";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.gepetto.flakeModule ];
      perSystem =
        {
          lib,
          pkgs,
          self',
          ...
        }:
        {
          devShells = {
              default = pkgs.mkShell {
                name = "Gepetto Main Dev Shell";
                CMAKE_C_COMPILER_LAUNCHER = "ccache";
                CMAKE_CXX_COMPILER_LAUNCHER = "ccache";
                CMAKE_GENERATOR = "Unix Makefiles";
                ROS_PACKAGE_PATH = "${pkgs.example-robot-data}/share";
                shellHook = ''
                  export DEVEL_HPP_DIR=$(pwd -P)
                  mkdir -p $DEVEL_HPP_DIR/{src,install}
                  export INSTALL_HPP_DIR=$DEVEL_HPP_DIR/install
                  export PATH=$INSTALL_HPP_DIR/bin:$PATH
                  export LD_LIBRARY_PATH=$INSTALL_HPP_DIR/lib
                  export PYTHONPATH=$INSTALL_HPP_DIR/${pkgs.python3.sitePackages}
                  export GEPETTO_GUI_PLUGIN_DIRS=$INSTALL_HPP_DIR/lib/gepetto-gui-plugins
                  export HPP_PLUGIN_DIRS=$INSTALL_HPP_DIR/lib/hppPlugins
                '';
                packages =
                  with pkgs;
                  [
                    (
                      buildEnv {
                        name = "ros";
                        paths = [
                          # keep-sorted start
                          pkgs.python3Packages.example-robot-data # for availability in AMENT_PREFIX_PATH
                          pkgs.python3Packages.hpp-tutorial # for availability in AMENT_PREFIX_PATH
                          pkgs.rosPackages.humble.ros-core
                          # pkgs.rosPackages.humble.turtlesim
                          pkgs.rosPackages.humble.agimus-controller-ros
                          pkgs.rosPackages.humble.agimus-msgs
                          # keep-sorted end
                        ];
                      }
                    )
                    gz-harmonic
                    colcon
                    assimp
                    ccache
                    cddlib
                    clp
                    cmake
                    console-bridge
                    doxygen
                    eigen
                    glpk
                    graphviz
                    jrl-cmakemodules
                    libGL
                    libsForQt5.full
                    octomap
                    openscenegraph
                    osgqt
                    pkg-config
                    (python3.withPackages (
                      p: with p; [
                        lxml
                        numpy
                        omniorb
                        omniorbpy
                        python-qt
                        scipy
                        (toPythonModule rosPackages.rolling.xacro)
                        # keep-sorted start
                        agimus-controller
                        agimus-controller-examples
                        crocoddyl
                        gepetto-gui
                        hpp-corba
                        ipython
                        matplotlib
                        # keep-sorted end
                      ]
                    ))
                    python3Packages.boost
                    qhull
                    qpoases
                    tinyxml-2
                    urdfdom
                    zlib
                  ]
                  ++ lib.optionals stdenv.isLinux [
                    psmisc
                  ];
              };
          };
        };
    };
}
