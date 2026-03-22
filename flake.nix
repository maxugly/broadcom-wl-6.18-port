{
  description = "Broadcom-WL Kernel 6.18 Porting Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        # 1. The Tools
        nativeBuildInputs = with pkgs; [
          llvmPackages_19.clang
          llvmPackages_19.lld
          gnumake
          git
          kmod # For modinfo/insmod
        ];

        # 2. Environment Variables
        shellHook = ''
          export CC=clang
          export KERNEL_VERSION="6.18.18-x64v2-xanmod1"
          echo "--- Broadcom Porting Shell Active ---"
          echo "Target Kernel: $KERNEL_VERSION"
          echo "Compiler: $(clang --version | head -n 1)"

          # Check if headers exist, if not, warn Jules
          if [ ! -d "/lib/modules/$KERNEL_VERSION/build" ]; then
            echo "WARNING: Kernel headers for $KERNEL_VERSION not found in /lib/modules/"
            echo "Please run your setup-jules.sh script to install them."
          fi
        '';
      };
    };
}