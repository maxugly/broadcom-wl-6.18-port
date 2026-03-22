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
          kmod 
        ];

        # 2. Environment Variables & Setup
        shellHook = ''
          export CC=clang
          export KERNEL_VERSION="6.18.18-x64v2-xanmod1"
          export KERN_DIR="/lib/modules/$KERNEL_VERSION"
          
          # This is the "Shortcut" for Jules to build against the 6.18 headers
          alias jbuild="make KBASE=$KERN_DIR"

          echo "--- Broadcom Porting Lab Active ---"
          echo "Target Kernel: $KERNEL_VERSION"
          echo "Compiler: $(clang --version | head -n 1)"
          echo "Shortcut: Type 'jbuild' to start the compilation."
          
          # Check if headers exist, if not, warn Jules
          if [ ! -d "$KERN_DIR/build" ]; then
            echo ""
            echo "!! WARNING: Kernel headers for $KERNEL_VERSION not found !!"
            echo "Please run: sudo ./setup-jules.sh"
            echo ""
          fi
        '';
      };
    };
}