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
                name = "AGIMUS Main Dev Shell no ros";
                shellHook = ''
                  export PYTHONPATH=${pkgs.python310.withPackages (p: [
                    p.gepetto-gui
                    p.hpp-corba
                    p.crocoddyl
                    p.example-robot-data
                    p.mim-solvers
                    p.pinocchio
                  ])}/${pkgs.python310.sitePackages}:$PYTHONPATH
                  export LD_LIBRARY_PATH=${pkgs.python310.withPackages (p: [
                    p.gepetto-gui
                    p.hpp-corba
                    p.crocoddyl
                    p.example-robot-data
                    p.mim-solvers
                    p.pinocchio
                  ])}/lib:$LD_LIBRARY_PATH
                '';
                packages = [
                  # keep-sorted start  
                  (pkgs.python310.withPackages (p: [
                    p.gepetto-gui
                    p.hpp-corba
                    p.crocoddyl
                    p.example-robot-data
                    p.mim-solvers
                    p.pinocchio
                  ]))
                  # keep-sorted end
                ];
              };
          };
        };
    };
}
