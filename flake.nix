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
                packages = [
                  # keep-sorted start  
                  (pkgs.python3.withPackages (p: [
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
