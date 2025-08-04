{
  description = "Agimus environment";

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
              name = "Agimus Dev Shell";
              
              buildInputs = [
                # Outils de compilation C++ et ROS
                pkgs.cmake
                pkgs.ccache

                # gazebo
                pkgs.gz-harmonic

                # Paquets ROS 2 de base
                pkgs.rosPackages.humble.ros-core
                pkgs.rosPackages.humble.ament-cmake-auto
                pkgs.rosPackages.humble.ament-cmake-python
                pkgs.rosPackages.humble.ament-cmake
                # pkgs.rosPackages.humble.ament-package
                # Ajoutez ici les autres paquets ROS 2 dont vous dépendez (ex: pkgs.rosPackages.humble.rclcpp)
                pkgs.rosPackages.humble.generate-parameter-library
                pkgs.rosPackages.humble.generate-parameter-library-py
                pkgs.rosPackages.humble.controller-manager
                pkgs.rosPackages.humble.linear-feedback-controller-msgs
                pkgs.rosPackages.humble.linear-feedback-controller

                # Franka packages
                pkgs.rosPackages.humble.franka-ros2 # beugué !
                # pkgs.rosPackages.humble.franka-description
                # pkgs.rosPackages.humble.franka-gripper
                # pkgs.rosPackages.humble.franka-hardware
                # pkgs.rosPackages.humble.franka-ign-ros2-control # beugué !
                # pkgs.rosPackages.humble.franka-robot-state-broadcaster
                # pkgs.rosPackages.humble.gripper-controllers

                # other packages
                pkgs.rosPackages.humble.eigen3-cmake-module

                (pkgs.python3.withPackages (p: [
                  p.gepetto-gui
                  p.hpp-corba
                  p.crocoddyl
                  p.example-robot-data
                  p.mim-solvers
                  p.pinocchio
                  p.jinja2
                  # p.setuptools # needed to build franka dependancies
                ]))
              ];

              shellHook = ''
                echo "Bienvenue dans l'environnement de développement Agimus !"
              '';
            };
          };
        };
    };
}
