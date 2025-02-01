  # shell.nix
with import <nixpkgs> {};
pkgs.mkShell {
  buildInputs = [
     (pkgs.rWrapper.override {
       packages = with pkgs.rPackages; [
         sf
      ]; # Include sf inside Nix
     })
     julia-lts
     curl
     gdal
     proj
     sqlite
     geos
     which
     nix-ld
  ];
  NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
    gcc  # ...
    gfortran
    stdenv
    openspecfun
    curl
    proj
    sqlite
    geos
    libssh2
    R
    julia
  ];
  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
    shellHook = ''
    export R_HOME="${pkgs.R}/lib/R"
    export R_LIBS="${pkgs.R}/lib/R/library"
    export LD_LIBRARY_PATH="${pkgs.R}/lib/R/lib:$LD_LIBRARY_PATH"

    echo "Environment variables for R set."
  '';

}
