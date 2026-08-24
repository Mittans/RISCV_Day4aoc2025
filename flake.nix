{
  description = "Cross-platform RISC-V build environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                llvmPackages.clang-unwrapped
                cmake
                # Bare-metal binutils (as, ld) for RISC-V
                pkgsCross.riscv64-embedded.buildPackages.binutils
              ]
              ++ lib.optionals stdenv.hostPlatform.isLinux [
                qemu
              ]
              ++ lib.optionals stdenv.hostPlatform.isDarwin [
                spike
                riscv-pk
              ];

            shellHook = ''
              echo 'run using `cmake -B build && qemu-riscv64 -strace build/test day4.txt`'
            '';
          };
        }
      );
    };
}
