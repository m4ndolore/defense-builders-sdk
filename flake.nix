{
  description = "Defense Builders SDK development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Node.js and package managers
            nodejs_20
            nodePackages.pnpm
            nodePackages.npm
            nodePackages.yarn
            
            # Python and Django
            python311
            python311Packages.pip
            python311Packages.virtualenv
            
            # Database
            postgresql_15
            redis
            
            # Development tools
            git
            curl
            wget
            jq
            
            # Build tools
            gnumake
            gcc
          ];
          
          shellHook = ''
            echo "🚀 Defense Builders SDK Development Environment"
            echo "================================================"
            echo "Node.js: $(node --version)"
            echo "Python: $(python --version)"
            echo "pnpm: $(pnpm --version)"
            echo ""
            echo "Available commands:"
            echo "  pnpm dev        - Start all services"
            echo "  pnpm web:dev    - Start Next.js frontend"
            echo "  pnpm api:dev    - Start Django backend"
            echo ""
          '';
        };
      });
}