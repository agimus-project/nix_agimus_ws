{
  description = "CHANGEME";

  inputs = {
    gepetto.url = "github:nim65s/gepetto-nix/gz";
    nix-ros-overlay.follows = "gepetto/nix-ros-overlay";
    gazebo-sim-overlay.follows = "gepetto/gazebo-sim-overlay";
    flake-parts.follows = "gepetto/flake-parts";
    nixpkgs.follows = "gepetto/nixpkgs";
    systems.follows = "gepetto/systems";
    treefmt-nix.follows = "gepetto/treefmt-nix";

  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.gepetto.flakeModule
        {
          gepetto-pkgs.overlays = [
            (final: prev: {
              # Overlay for system-wide pybind11
              pybind11 = prev.pybind11.overrideAttrs (oldAttrs: {
                doCheck = false;
                doInstallCheck = false;
                doBenchmark = false;
                cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [ "-DPYBIND11_TEST=OFF" ];
              });
              # Extension for python310's pythonPackages
              pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                (
                  python-final: python-prev: {
                    pybind11 = python-prev.pybind11.overridePythonAttrs (oldAttrs: {
                      doCheck = false;
                      doInstallCheck = false;
                      doBenchmark = false;
                      cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [ "-DPYBIND11_TEST=OFF" ];
                    });
                  }
                )
              ];
            })
          ];
        }
      ];
      perSystem =
        {
          lib,
          pkgs,
          self',
          ...
        }:
        {
          packages = {
            pybind11 = pkgs.python310.withPackages (p: [ p.pybind11 ]);
          };
          devShells = {
              default = pkgs.mkShell {
                name = "AGIMUS Main Dev Shell no ros";
                shellHook = ''
                  export PYTHONPATH=${pkgs.python310.withPackages (p: [
                    p.gepetto-gui
                  ])}/${pkgs.python310.sitePackages}:$PYTHONPATH:/usr/local/lib/python3/dist-packages:/usr/lib/python3/dist-packages
                  export LD_LIBRARY_PATH=${pkgs.python310.withPackages (p: [
                    p.gepetto-gui
                  ])}/lib:$LD_LIBRARY_PATH
                '';
                packages = [
                  # keep-sorted start  
                  (pkgs.python310.withPackages (p: [
                    p.colmpc
                    p.crocoddyl
                    p.example-robot-data
                    p.gepetto-gui
                    p.hpp-corba
                    p.mim-solvers
                    p.pinocchio
                    p.pybind11
                  ]))
                  # keep-sorted end
                ];
              };
          };
        };
    };
}
